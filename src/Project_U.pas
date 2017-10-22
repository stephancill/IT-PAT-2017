unit Project_U;

interface

uses Assignment_U, User_U, Classroom_U;

type
TProject = Class(TObject)
  private
    classroom: TClassroom;
    assignment: TAssignment;
    creator: TUser;
    id, directory: string;

  public
    // Getters
    function getClassroom: TClassroom;
    function getAssignment: TAssignment;
    function getCreator: TUser;
    function getID: string;
    function getDirectory: string;

    constructor Create(id, directory: string; user: TUser; assignment: TAssignment); overload;
  End;

  TProjectArray = array of TProject;

implementation


{ TProject }


constructor TProject.Create(id, directory: string; user: TUser; assignment: TAssignment);
begin
  self.id := id;
  self.directory := directory;
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

function TProject.getDirectory: string;
begin
  result := self.directory;
end;

function TProject.getID: string;
begin
  result := self.id;
end;

end.
