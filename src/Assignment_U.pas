unit Assignment_U;

interface

uses Classroom_U;

type
TAssignment = Class(TObject)
  private
    id, title, dateIssued, classroomID, description: string;
    classroom: TClassroom;

  public
    // Getters
    function getID: string;
    function getTitle: string;
    function getDescription: string;
    function getDateIssued: string;

    constructor Create(id, title, dateIssued, description: string; classroom: TClassroom); overload;
  End;

  TAssignmentArray = array of TAssignment;

implementation




{ TAssignment }


constructor TAssignment.Create(id, title, dateIssued, description: string; classroom: TClassroom);
begin
  self.id := id;
  self.title := title;
  self.dateIssued := dateIssued;
  self.description := description;
  self.classroom := classroom;
end;

function TAssignment.getDateIssued: string;
begin
  result := self.dateIssued;
end;

function TAssignment.getDescription: string;
begin
  result := self.description;
end;

function TAssignment.getID: string;
begin
  result := self.id;
end;

function TAssignment.getTitle: string;
begin
  result := self.title;
end;

end.
