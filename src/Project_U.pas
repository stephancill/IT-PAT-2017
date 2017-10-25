unit Project_U;

interface

uses Assignment_U, User_U, Classroom_U, SysUtils;

type
TProject = Class(TObject)
  private
    classroom: TClassroom;
    assignment: TAssignment;
    creator: TUser;
    id, location: string;

  public
    // Getters
    function getClassroom: TClassroom;
    function getAssignment: TAssignment;
    function getCreator: TUser;
    function getID: string;
    function getLocation: string;
    function getLocalDirectory: string; overload;

    class function getLocalDirectory(assignment: TAssignment; student: TUser): string; overload;

    constructor Create(id, location: string; creator: TUser; assignment: TAssignment); overload;
  End;

  TProjectArray = array of TProject;

implementation


{ TProject }


constructor TProject.Create(id, location: string; creator: TUser; assignment: TAssignment);
begin
  self.id := id;
  self.location := location;
  self.creator := creator;
  self.assignment := assignment;
  self.classroom := assignment.getClassroom;
end;

function TProject.getAssignment: TAssignment;
begin
  result := self.assignment;
end;

function TProject.getClassroom: TClassroom;
begin
  result := self.classroom;
end;

function TProject.getCreator: TUser;
begin
  result := self.creator;
end;

function TProject.getLocalDirectory: string;
var
  projectsDir, tmp: string;
begin
  result := getLocalDirectory(assignment, creator);
end;

class function TProject.getLocalDirectory(assignment: TAssignment;
  student: TUser): string;
var
  projectsDir: string;
begin
  projectsDir := GetCurrentDir + '\..\Projects';
  result :=  projectsDir + Format('\%s\%s\%s\%s', [assignment.getClassroom.getTeacherID, assignment.getClassroom.getName, assignment.getTitle, student.getFullName]);
end;

function TProject.getLocation: string;
begin
  result := self.location;
end;

function TProject.getID: string;
begin
  result := self.id;
end;

end.
