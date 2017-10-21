unit Classroom_U;

interface

uses User_U;

type

TClassroom = Class(TObject)
  private
    id, name, teacherID: string;
  public
    // Getters
    function getID(): string;
    function getName: string;
    function getTeacherID: string;

    constructor Create(id, name, teacherID: string); overload;
  End;

  TClassroomArray = array of TClassroom;

implementation

{ TClassroom }

constructor TClassroom.Create(id, name, teacherID: string);
begin
  self.id := id;
  self.name := name;
  self.teacherID := teacherID;
end;

function TClassroom.getID: string;
begin
  result := self.id;
end;

function TClassroom.getName: string;
begin
  result := self.name;
end;

function TClassroom.getTeacherID: string;
begin
  result := self.teacherID;
end;

end.
