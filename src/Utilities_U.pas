unit Utilities_U;

interface

uses DB, ADODB, SysUtils, StrUtils, Math, Dialogs, IdGlobal, IdHash,
  IdHashMessageDigest, User_U, Classroom_U, Assignment_U, Project_U;

type
  Utilities = Class
  private const
    TAG: string = 'UTILITIES';
    // Database
    class function queryDatabase(query: string; var qry: TADOQuery): TADOQuery;
    class function modifyDatabase(sql: string; var qry: TADOQuery): boolean;
    class function getEntityByID(table, id: string; var qry: TADOQuery): boolean;
  public
    const
      persistentLoginDestination: string = 'PERSISTED_LOGIN.txt';
    // Authentication
    class function registerUser(email, password, firstname, lastname: string;
      userType: Integer; var user: TUser): boolean;
    class function loginUser(email, password: string; var user: TUser; hashed: boolean = false): boolean;
    class procedure persistLogin(email, password: string; hashed: boolean);
    class procedure depersistLogin;
    class function getPersistedLogin(var email, password: string): boolean;

    // User
    class function changePassword(user: TUser; oldPassword, newPassword: string): boolean;
    class function updateUserInformation(user: TUser; var newUser: TUser): boolean;

    // Classroom - Teacher
    class function getTeachingClassrooms(user: TUser): TClassroomArray;
    class function createClassroom(user: TUser; name: string; var classroom: TClassroom): boolean;
    class function deleteClassroom(user: TUser; classroom: TClassroom): boolean;
    class function getStudents(classroom: TClassroom): TUserArray;

    // Classroom - Student
    class function getStudentClassrooms(user: TUser): TClassroomArray;
    class function joinClassroom(user: TUser; id: string; classroom: TClassroom): boolean;
    class function leaveClassroom(user: TUser; classroom: TClassroom): boolean;

    // Assignments
    class function getAssignments(classroom: TClassroom): TAssignmentArray;
    class function createAssignment(classroom: TClassroom;
      title, date, description: string; var assignment: TAssignment): boolean;

    // Project
    class function createProject(directory: string; creator: TUser; assignment: TAssignment; var project: TProject): boolean;

    // Misc
    class function userExists(email, password: string): boolean;
    class function getMD5Hash(s: string): string;
    class function getLastID(var query: TADOQuery { or TQuery } ): Integer;
    class procedure kill;

  end;

implementation

uses Data_Module_U, Logger_U, Forms;

{ Utilities }

class function Utilities.createProject(directory: string; creator: TUser;
  assignment: TAssignment; var project: TProject): boolean;
begin
  {
    1. Create project in Project table
    2. Create record in Student_Project junction-table
    3. Create record in Assignment_Project junction-table
    4. Create TProject object
    }

  // 1. Create project in Project table
  if not Utilities.modifyDatabase(
  Format('INSERT INTO Project ([ID], ClassID, AssignmentID, StudentID, Location) VALUES (%s, %s, %s, %s, %s)',
    [quotedStr(assignment.getID + '$' + creator.getID), assignment.getclassroom.getID, assignment.getID, creator.getID, quotedStr(directory)]), data_module.qry) then
    begin
    result := false;
    Exit;
  end;

  // 2. Create record in Student_Project junction-table
  if not Utilities.modifyDatabase(
  Format('INSERT INTO Student_Project (ProjectID, StudentID) VALUES (%s, %s)',
    [quotedStr(assignment.getID + '$' + creator.getID), creator.getID]), data_module.qry) then
    begin
    result := false;
    Exit;
  end;

  // 3. Create record in Assignment_Project junction-table
  if not Utilities.modifyDatabase(
  Format('INSERT INTO Assignment_Project (ProjectID, ClassroomID, AssignmentID) VALUES (%s, %s, %s)',
    [quotedStr(assignment.getID + '$' + creator.getID), assignment.getclassroom.getID, assignment.getID]), data_module.qry) then
  begin
    result := false;
    Exit;
  end;

  project := TProject.create(assignment.getID + '$' + creator.getID, directory, creator, assignment);

  TLogger.log(TAG, TLogType.Debug,
    'Created project with ID: ' + project.getID);

  result := true
end;

{ Authentication }
class function Utilities.registerUser(email, password, firstname,
  lastname: string; userType: Integer; var user: TUser): boolean;
var
  id: string;
begin
  {
    1. Check if user exists
    2. Create user in Users table
    3. Get generated ID
    4. Create user in Teacher/Student table with generated ID
    5. Create and return TUser object
    }

  // 1. Check if user exists
  if userExists(email, password) then
  begin
    Showmessage('Email already in use.');
    result := false;
    Exit;
  end;

  // 2. Create user in Users table
  if not modifyDatabase
    ('INSERT INTO Users (Email, [Password], Type) VALUES (' + quotedStr(email)
      + ',' + quotedStr(getMD5Hash(password)) + ',' + inttostr(userType) + ')',
    data_module.qry) then
  begin
    TLogger.log(TAG, TLogType.Error, 'Failed to INSERT new user record into Users table');
    result := false;
    Exit;
  end;

  // 3. Get generated ID
  id := inttostr(getLastID(data_module.qry));

  // 4. Create user in Teacher or Student table with generated ID
  if not modifyDatabase('INSERT INTO ' + IfThen(userType = 1, 'Student',
      'Teacher') + ' ([ID], Email, FirstName, LastName) VALUES (' + id + ',' +
      quotedStr(email) + ',' + quotedStr(firstname) + ',' + quotedStr(lastname)
      + ')', data_module.qry) then
    begin
      TLogger.log(TAG, TLogType.Error, 'Failed to INSERT new user record into ' + IfThen(userType = 1, 'Student',
      'Teacher') + ' table');
      result := false;
      Exit;
    end;

  // 5. Create and return TUser object
  user := TUser.Create(id, email, firstname, lastname, TUserType(userType));

  TLogger.log(TAG, TLogType.Debug, 'Registered user with ID ' + user.getID);

  result := true;
end;

class function Utilities.loginUser(email, password: string;
  var user: TUser; hashed: boolean = false): boolean;
var
  qry: TADOQuery;
  id, firstname, lastname: string;
  userType: Integer;
begin
  {
    1. Check if user exists
    2. Retrieve **user type** and ID with entered email/password combination
    3. Retrieve user from Teacher/Student table with ID
    4. Create and return TUser object
    }
  if not hashed then
    password := getMD5Hash(password);

  qry := queryDatabase('SELECT * FROM Users WHERE email = ' + quotedStr(email)
      + ' AND password = ' + quotedStr(password), data_module.qry);

  // 1. Check if user exists
  if not qry.Eof then
  begin
    // 2. Retrieve **user type** and ID with entered email/password combination
    id := qry.FieldByName('ID').AsString;
    userType := qry.FieldByName('Type').AsInteger;

    // 3. Retrieve user from Teacher/Student table with ID
    qry := queryDatabase('SELECT * FROM ' + IfThen(userType = 1, 'Student',
        'Teacher') + ' WHERE ID = ' + id, data_module.qry);

    firstname := qry.FieldByName('FirstName').AsString;
    lastname := qry.FieldByName('LastName').AsString;

    // 4. Create and return TUser object
    user := TUser.Create(id, email, firstname, lastname, TUserType(userType));

    TLogger.log(TAG, TLogType.Debug,
      'Successfully logged in user with email: ' + email);

    result := true;
    Exit;
  end
  else
    result := false;

  TLogger.log(TAG, TLogType.Error, 'Failed login attempt with email: ' + email);

end;

class procedure Utilities.persistLogin(email, password: string; hashed: boolean);
var
  f: TextFile;
begin
  TLogger.log(TAG, TLogType.Debug, 'Persisting login for user with email: ' + email);

  if not hashed then
    password := getMD5Hash(password);

  AssignFile(f, persistentLoginDestination);
  try
    Rewrite(f);
    writeLn(f, email);
    writeLn(f, password);
    CloseFile(f);
  except
    on E: Exception do
    begin
      Showmessage('Something went wrong... Check logs for more information.');
      TLogger.logException(TAG, 'persistLogin', e);
      Exit;
    end;
  end;
end;

class procedure Utilities.depersistLogin;
begin
  DeleteFile(persistentLoginDestination);
end;

class function Utilities.getPersistedLogin(var email, password: string): boolean;
var
  f: TextFile;
begin
  AssignFile(f, persistentLoginDestination);
  try
    Reset(f);
    readln(f, email);
    readln(f, password);
    Closefile(f);
  except
    on E: Exception do
    begin
      Showmessage('Something went wrong... Check logs for more information.');
      TLogger.logException(TAG, 'getPersistedLogin', e);
      result := false;
      Exit;
    end;
  end;

  result := true;
end;

{ User }
class function Utilities.changePassword(user: TUser; oldPassword,
  newPassword: string): boolean;
var
  qry: TADOQuery;
begin
  // Check if old password is correct
  qry := queryDatabase('SELECT * FROM Users WHERE [ID] = ' + user.getID + ' AND [Password] = ' + QuotedStr(getMD5Hash(oldPassword)), data_module.qry);

  if qry.eof then
  begin
    TLogger.log(TAG, TLogType.Debug, 'Failed to change password of user with ID: ' + user.getID);
    result := false;
    Exit;
  end;

  // Update password
  result := Utilities.modifyDatabase('UPDATE Users SET [Password] = ' + QuotedStr(getMD5Hash(newPassword)) +
  ' WHERE [ID] = ' + user.getID, data_module.qry);

  if result then
  begin
    TLogger.log(TAG, TLogType.Debug, 'Successfully changed password of user with ID: ' + user.getID);
  end else
  begin
    TLogger.log(TAG, TLogType.Debug, 'Failed to change password of user with ID: ' + user.getID);
  end;
end;

class function Utilities.updateUserInformation(user: TUser; var newUser: TUser): boolean;
var
  table: string;
begin
  case user.getType of
    Student: table := 'Student';
    Teacher: table := 'Teacher';
  end;
  // Update password
  result := Utilities.modifyDatabase('UPDATE ' + table + ' SET ' +
  'Email = ' + QuotedStr(newUser.getEmail) + ', ' +
  'FirstName = ' + QuotedStr(newUser.getFirstName) + ', ' +
  'LastName = ' + QuotedStr(newUser.getLastName) +
  ' WHERE [ID] = ' + user.getID, data_module.qry);

  if not (user.getEmail = newUser.getEmail) then
  begin
    result := result and
    Utilities.modifyDatabase('UPDATE Users SET Email = ' + QuotedStr(newUser.getEmail) +
    ' WHERE [ID] = ' + user.getID, data_module.qry);
  end;

  if result then
  begin
    TLogger.log(TAG, TLogType.Debug, 'Successfully changed information of user with ID: ' + user.getID);
  end else
  begin
    TLogger.log(TAG, TLogType.Debug, 'Failed to change information of user with ID: ' + user.getID);
  end;
end;


{ Classroom - Teacher }
class function Utilities.getTeachingClassrooms(user: TUser): TClassroomArray;
var
  qry: TADOQuery;
begin
  qry := Utilities.queryDatabase
    ('SELECT * FROM Classroom WHERE Teacher = ' + user.getID, data_module.qry);

  while not qry.Eof do
  begin
    SetLength(result, length(result) + 1);
    result[length(result) - 1] := TClassroom.Create
      (qry.FieldByName('ID').AsString, qry.FieldByName('ClassName').AsString,
      qry.FieldByName('Teacher').AsString);
    qry.Next;
  end;

  TLogger.log(TAG, TLogType.Debug, 'Got ' + inttostr(length(result)) +
      ' classrooms for teacher with ID: ' + user.getID);
end;


class function Utilities.createClassroom(user: TUser; name: string;
  var classroom: TClassroom): boolean;
begin
  {
    1. Check if classroom name exists
    2. Create classroom in Classroom table
    3. Get generated ID
    }
  // 1. Check if name already exists
  if not Utilities.queryDatabase
    ('SELECT * FROM Classroom WHERE Teacher = ' + user.getID +
      ' AND ClassName = ' + quotedStr(name), data_module.qry).Eof then
  begin
    TLogger.log(TAG, TLogType.Debug,
      'Attempted to create classroom that already exists.');
    Showmessage('Classroom name already exists');
    Exit;
  end;

  // 2. Create classroom in Classroom table
  if not Utilities.modifyDatabase(
    'INSERT INTO Classroom (Teacher, ClassName) VALUES (' + user.getID + ',' +
      quotedStr(name) + ')', data_module.qry) then
  begin
    Exit;
  end;


  // 3. Get generated ID
  classroom := TClassroom.Create
    (inttostr(Utilities.getLastID(data_module.qry)), name, user.getID);

  TLogger.log(TAG, TLogType.Debug,
    'Created classroom with ID: ' + classroom.getID);

  result := true;
end;



class function Utilities.deleteClassroom(user: TUser;
  classroom: TClassroom): boolean;
begin
  if not modifyDatabase('DELETE FROM Classroom WHERE ID = ' + classroom.getID +
      ' AND Teacher = ' + user.getID, data_module.qry) then
  begin
    result := false;
    Exit;
  end;


  TLogger.log(TAG, TLogType.Debug,
    'Deleted classroom with ID: ' + classroom.getID);
  result := true;
end;



class function Utilities.getStudents(classroom: TClassroom): TUserArray;
var
  qry: TADOQuery;
  qryAlt: TADOQuery;
begin
  qry := Utilities.queryDatabase(
    'SELECT * FROM Student_Classroom WHERE ClassroomID = ' + classroom.getID,
    data_module.qry);

  while not qry.Eof do
  begin
    SetLength(result, length(result) + 1);

    Utilities.getEntityByID('Student', qry.FieldByName('StudentID').AsString,
      qryAlt);

    result[length(result) - 1] := TUser.Create
      (qryAlt.FieldByName('ID').AsString,
      qryAlt.FieldByName('Email').AsString,
      qryAlt.FieldByName('Firstname').AsString,
      qryAlt.FieldByName('Lastname').AsString, TUserType.Student);
    qry.Next;
  end;

  TLogger.log(TAG, TLogType.Debug, 'Got ' + inttostr(length(result)) +
      ' students for classroom with ID: ' + classroom.getID);

end;

{ Classroom - Students }
class function Utilities.joinClassroom(user: TUser; id: string; classroom: TClassroom): boolean;
var
  qry: TADOQuery;
begin
  // 1. Check if classroom with specified ID exist
  qry := Utilities.queryDatabase
    ('SELECT * FROM Classroom WHERE ID = ' + id, data_module.qry);

  if qry.Eof then
  begin
    Showmessage('Classroom with that code does not exist.');
    TLogger.log(TAG, TLogType.Debug, 'Tried to join a classroom that does not exist');
    result := false;
    Exit;
  end;

  // 2. Insert into Student_Classroom junction table
  if not modifyDatabase(Format('INSERT INTO Student_Classroom (StudentID, ClassroomID) VALUES (%s, %s)', [user.getID, id]), data_module.qry) then
  begin
    TLogger.log(TAG, TLogType.Error, 'Failed to INSERT into Student_Classroom');
    result := false;
    Exit;
  end;


  TLogger.log(TAG, TLogType.Debug, 'Student with ID: ' + user.getID + ' joined classroom with ID: ' + id);
  result := true;
end;

class function Utilities.leaveClassroom(user: TUser;
  classroom: TClassroom): boolean;
begin
  if not modifyDatabase(Format('DELETE FROM Student_Classroom WHERE StudentID = %s AND ClassroomID = %s', [user.getID, classroom.getID]), data_module.qry) then
  begin
    TLogger.log(TAG, TLogType.Error, 'Failed to delete record from Student_Classroom table');
    result := false;
    Exit;
  end;

  TLogger.log(TAG, TLogType.Debug,
    'Student with ID: ' + user.getID + ' left classroom with ID: ' + classroom.getID);
  result := true;
end;

class function Utilities.getStudentClassrooms(user: TUser): TClassroomArray;
var
  qry, qryAlt: TADOQuery;
begin
  qry := Utilities.queryDatabase
    ('SELECT * FROM Student_Classroom WHERE StudentID = ' + user.getID, data_module.qry);


  while not qry.Eof do
  begin
    qryAlt := Utilities.queryDatabase
    ('SELECT * FROM Classroom WHERE [ID] = ' + qry.FieldByName('ClassroomID').AsString, data_module.qryAux);

    if not qryAlt.Eof then
    begin
      SetLength(result, length(result) + 1);
      result[length(result) - 1] := TClassroom.Create
        (qryAlt.FieldByName('ID').AsString, qryAlt.FieldByName('ClassName').AsString,
        qryAlt.FieldByName('Teacher').AsString);

    end else
    begin
      TLogger.log(TAG, TLogType.Debug, 'Could not find classroom with ID: ' + qry.FieldByName('ClassroomID').AsString);
    end;

    qry.Next;
  end;

  TLogger.log(TAG, TLogType.Debug, 'Got ' + inttostr(length(result)) +
      ' classrooms for student with ID: ' + user.getID);

end;

{ Assignments }
class function Utilities.getAssignments(classroom: TClassroom)
  : TAssignmentArray;
var
  qry: TADOQuery;
begin
  qry := Utilities.queryDatabase
    ('SELECT * FROM Assignment WHERE Class = ' + classroom.getID +
      ' ORDER BY DateIssued ASC', data_module.qry);

  while not qry.Eof do
  begin
    SetLength(result, length(result) + 1);
    result[length(result) - 1] := TAssignment.Create
      (qry.FieldByName('ID').AsString, qry.FieldByName('Title').AsString,
      qry.FieldByName('DateIssued').AsString,
      qry.FieldByName('Description').AsString, classroom);
    qry.Next;
  end;

  TLogger.log(TAG, TLogType.Debug, 'Got ' + inttostr(length(result)) +
      ' assignments for classroom with ID: ' + classroom.getID);
end;

class function Utilities.createAssignment(classroom: TClassroom;
  title, date, description: string; var assignment: TAssignment): boolean;
begin
  {
    1. Create assignment in Assignment table
    2. Create TAssignment object
    }

  // 1. Create assignment in Classroom table
  if not Utilities.modifyDatabase(
    'INSERT INTO Assignment (Class, Title, DateIssued, Description) VALUES (' +
      classroom.getID + ',' + quotedStr(title) + ',' + quotedStr(date)
      + ',' + quotedStr(description) + ')', data_module.qry) then
    Exit;

  // 2. Create TAssignment object
  assignment := TAssignment.Create(inttostr(getLastID(data_module.qry)), title, date, description, classroom);

  TLogger.log(TAG, TLogType.Debug,
    'Created assignment with ID: ' + assignment.getID +
      ' in classroom with ID: ' + classroom.getID);

  result := true
end;

{ Misc }
class function Utilities.userExists(email, password: string): boolean;
begin
  result := not queryDatabase('SELECT * FROM Users WHERE email = ' + quotedStr
      (email) + ' AND password = ' + quotedStr(getMD5Hash(password)),
    data_module.qry).Eof;
end;

// http://www.swissdelphicenter.com/en/showcode.php?id=1749
class function Utilities.getLastID(var query: TADOQuery): Integer;
begin
  result := -1;
  try
    query.sql.clear;
    query.sql.Add('SELECT @@IDENTITY');
    query.Active := true;
    query.First;
    result := query.Fields.Fields[0].AsInteger;
  finally
    query.Active := false;
    query.sql.clear;
  end;
end;

// https://stackoverflow.com/a/18233500
class function Utilities.getMD5Hash(s: string): string;
var
  hashMessageDigest5: TIdHashMessageDigest5;
begin
  hashMessageDigest5 := nil;
  try
    hashMessageDigest5 := TIdHashMessageDigest5.Create;
    result := IdGlobal.IndyLowerCase(hashMessageDigest5.HashStringAsHex(s));
  finally
    hashMessageDigest5.Free;
  end;
end;

 { Database }
class function Utilities.modifyDatabase(sql: string;
  var qry: TADOQuery): boolean;
begin
  try
    qry.Close;
    qry.sql.clear;
    qry.sql.Add(sql);
    qry.ExecSQL;
    result := true;
  except
    on E: Exception do
    begin
      Showmessage('Something went wrong... Check logs for more information.');
      TLogger.logException(TAG, 'modifyDatabase ' + sql, e);
      result := false;
      Exit;
    end;
  end;

end;

class function Utilities.queryDatabase(query: string;
  var qry: TADOQuery): TADOQuery;
begin
  try
    qry.Close;
    qry.sql.clear;
    qry.sql.Add(query);
    qry.Open;

    result := qry;
  except
    on E: Exception do
    begin
      Showmessage('Something went wrong... Check logs for more information.');
      TLogger.logException(TAG, 'queryDatabase ' + query, e);
      Exit;
    end;
  end;

end;

class function Utilities.getEntityByID(table, id: string;
  var qry: TADOQuery): boolean;
begin
  qry := Utilities.queryDatabase
    ('SELECT * FROM ' + table + ' WHERE ID = ' + id, data_module.qryAux);

  if qry.Eof then
  begin
    result := false;
    Exit;
  end;

  result := true;
end;

class procedure Utilities.kill;
begin
  Application.Terminate;
end;

end.
