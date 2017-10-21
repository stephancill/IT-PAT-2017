unit Utilities_U;

interface

uses DB, ADODB, SysUtils, StrUtils, Math, Dialogs, IdGlobal, IdHash,
  IdHashMessageDigest, User_U, Classroom_U, Assignment_U;

type
  Utilities = Class
  private
    class function queryDatabase(query: string): TADOQuery;
    class function userExists(email, password: string): boolean;
    class function getMD5Hash(s: string): string;
    class function getLastID(var query: TADOQuery { or TQuery } ): Integer;
    class procedure modifyDatabase(sql: string);
  public
    // Authentication
    class function registerUser(email, password, firstname, lastname: string;
      userType: Integer; var user: TUser): boolean;
    class function loginUser(email, password: string; var user: TUser): boolean;

    // Classroom - Teacher
    class function getTeachingClassrooms(user: TUser): TClassroomArray;
    class function createClassroom(user: TUser; name: string;
      var classroom: TClassroom): boolean;
    class function deleteClassroom(user: TUser; classroom: TClassroom): boolean;
    class function getStudents(classroom: TClassroom): TUserArray;

    // Assignments
    class function getAssignments(classroom: TClassroom): TAssignmentArray;
    class function createAssignment(classroom: TClassroom; title, date,description: string;
      var assignment: TAssignment): boolean;

    // Misc
    class function getEntityByID(table, id: string; fields: TFields): boolean;

  end;

implementation

uses Data_Module_U;

{ Utilities }

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

  try
    // 2. Create user in Users table
    modifyDatabase('INSERT INTO Users (Email, [Password], Type) VALUES (' +
        quotedStr(email) + ',' + quotedStr(getMD5Hash(password))
        + ',' + inttostr(userType) + ')');

    // 3. Get generated ID
    id := inttostr(getLastID(data_module.qry));

    // 4. Create user in Teacher or Student table with generated ID
    modifyDatabase('INSERT INTO ' + IfThen(userType = 1, 'Student',
        'Teacher') + ' ([ID], Email, FirstName, LastName) VALUES (' + id +
        ',' + quotedStr(email) + ',' + quotedStr(firstname) + ',' + quotedStr
        (lastname) + ')');

  except
    on E: Exception do
    begin
      Showmessage('Exception class name = ' + E.ClassName + #13 +
          'Exception message = ' + E.Message);
      result := false;
      Exit;
    end;
  end;

  // 5. Create and return TUser object
  user := TUser.Create(id, email, firstname, lastname, TUserType(userType));
  result := true;
end;

class function Utilities.loginUser(email, password: string;
  var user: TUser): boolean;
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

  qry := queryDatabase('SELECT * FROM Users WHERE email = ' + quotedStr(email)
      + ' AND password = ' + quotedStr(getMD5Hash(password)));

  // 1. Check if user exists
  if not qry.Eof then
  begin
    // 2. Retrieve **user type** and ID with entered email/password combination
    id := qry.FieldByName('ID').AsString;
    userType := qry.FieldByName('Type').AsInteger;

    // 3. Retrieve user from Teacher/Student table with ID
    qry := queryDatabase('SELECT * FROM ' + IfThen(userType = 1, 'Student',
        'Teacher') + ' WHERE ID = ' + id);

    firstname := qry.FieldByName('FirstName').AsString;
    lastname := qry.FieldByName('LastName').AsString;

    // 4. Create and return TUser object
    user := TUser.Create(id, email, firstname, lastname, TUserType(userType));
    result := true;
    Exit;
  end
  else
    result := false;

end;

{ Classroom - Teacher }
class function Utilities.getTeachingClassrooms(user: TUser): TClassroomArray;
var
  qry: TADOQuery;
begin
  qry := Utilities.queryDatabase
    ('SELECT * FROM Classroom WHERE Teacher = ' + user.getID);

  while not qry.Eof do
  begin
    SetLength(result, length(result) + 1);
    result[length(result) - 1] := TClassroom.Create
      (qry.FieldByName('ID').AsString, qry.FieldByName('ClassName').AsString,
      qry.FieldByName('Teacher').AsString);
    qry.Next;
  end;
end;

class function Utilities.createClassroom(user: TUser; name: string;
  var classroom: TClassroom): boolean;
begin
  {
    1. Check if classroom name exists
    2. Create classroom in Classroom table
    3. Get generated ID
    4. Create entry in Teacher-Classroom junction table
    }
  // 1. Check if name already exists
  if not Utilities.queryDatabase
    ('SELECT * FROM Classroom WHERE Teacher = ' + user.getID +
      ' AND ClassName = ' + quotedStr(name)).Eof then
  begin
    result := false;
    Showmessage('Classroom name already exists');
    Exit;
  end;

  try
    // 2. Create classroom in Classroom table
    Utilities.modifyDatabase(
      'INSERT INTO Classroom (Teacher, ClassName) VALUES (' + user.getID +
        ',' + quotedStr(name) + ')');

    // 3. Get generated ID
    classroom := TClassroom.Create
      (inttostr(Utilities.getLastID(data_module.qry)), name, user.getID);

    // // 4. Create entry in Teacher-Classroom junction table
    // modifyDatabase('INSERT INTO Teacher-Classroom (TeacherID, ClassroomID) VALUES (' + user.getID + ',' + id + ')');
  except
    result := false;
    Exit;
  end;

  result := true;
end;

class function Utilities.deleteClassroom(user: TUser;
  classroom: TClassroom): boolean;
begin
  try
    modifyDatabase('DELETE FROM Classroom WHERE ID = ' + classroom.getID +
        ' AND Teacher = ' + user.getID);
  except
    result := false;
    Exit;
  end;

  result := true;
end;

{ Assignments }
class function Utilities.getAssignments(classroom: TClassroom): TAssignmentArray;
var
  qry: TADOQuery;
begin
  qry := Utilities.queryDatabase
      ('SELECT * FROM Assignment WHERE Class = ' + classroom.getID +
        ' ORDER BY DateIssued ASC');

  while not qry.Eof do
  begin
    SetLength(result, length(result) + 1);
    result[length(result) - 1] := TAssignment.Create
      (qry.FieldByName('ID').AsString, qry.FieldByName('Title').AsString,
      qry.FieldByName('DateIssued').AsString, qry.FieldByName('Description').AsString, classroom);
    qry.Next;
  end;
end;

class function Utilities.getEntityByID(table, id: string; fields: TFields): boolean;
var
  qry: TADOQuery;
begin
  qry := Utilities.queryDatabase
      ('SELECT * FROM ' + table + ' WHERE ID = ' + id);

  if qry.Eof then
  begin
    result := false;
    exit;
  end;

  fields := qry.Fields;
  result := true;
end;

class function Utilities.createAssignment(classroom: TClassroom; title, date, description: string;
  var assignment: TAssignment): boolean;
begin
  {
    1. Create assignment in Assignment table
    2. Create TAssignment object
    }

  // 1. Create assignment in Classroom table
  Utilities.modifyDatabase('INSERT INTO Assignment (Class, Title, DateIssued, Description) VALUES (' +
      classroom.getID + ',' + quotedStr(title) + ',' + quotedStr(date) + ',' + quotedStr(description) + ')');

  // 2. Get generated ID
  assignment := TAssignment.Create();

  result := true
end;

class function Utilities.userExists(email, password: string): boolean;
begin
  result := not queryDatabase('SELECT * FROM Users WHERE email = ' + quotedStr
      (email) + ' AND password = ' + quotedStr(getMD5Hash(password))).Eof;
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


class function Utilities.getStudents(classroom: TClassroom): TUserArray;
var
  qry: TADOQuery;
  fields: TFields;
begin
  qry := Utilities.queryDatabase
      ('SELECT * FROM ' + quotedStr('Student_Classroom') + ' WHERE Class = ' + classroom.getID);

  while not qry.Eof do
  begin
    SetLength(result, length(result) + 1);
    Utilities.getEntityByID('Student', qry.FieldByName('ID').AsString, fields);
    result[length(result) - 1] := TUser.Create(
      fields.FieldByName('ID').AsString,
      fields.FieldByName('email').AsString,
      fields.FieldByName('firstname').AsString,
      fields.FieldByName('lastname').AsString,
      TUserType(fields.FieldByName('UserType').AsInteger)
    );
//    showmessage(result[length(result) - 1].getfirstname);
    qry.Next;
  end;
end;

class procedure Utilities.modifyDatabase(sql: string);
begin
  data_module.qry.Close;
  data_module.qry.sql.clear;
  // showmessage(sql);
  data_module.qry.sql.Add(sql);

  data_module.qry.ExecSQL;
end;

class function Utilities.queryDatabase(query: string): TADOQuery;
begin
  data_module.qry.Close;
  data_module.qry.sql.clear;
  data_module.qry.sql.Add(query);
  data_module.qry.Open;

  result := data_module.qry;
end;

end.
