unit Create_Assignment_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Utilities_U, Classroom_U, ComCtrls, DateUtils, Assignment_U, Teacher_Home_U;

type
  TfrmCreateAssignment = class(TForm)
    edtTitle: TEdit;
    edtDescription: TRichEdit;
    btnCreate: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure btnCreateClick(Sender: TObject);
  private
    { Private declarations }
    classroom: TClassroom;
    sender: TfrmTeacherHome;
  public
    { Public declarations }
    procedure load(classroom: TClassroom; sender: TfrmTeacherHome);
  end;

var
  frmCreateAssignment: TfrmCreateAssignment;

implementation

{$R *.dfm}

{ TForm1 }

procedure TfrmCreateAssignment.btnCreateClick(Sender: TObject);
var
  assignment: TAssignment;
begin
  if Utilities.createAssignment(self.classroom, edtTitle.Text, datetostr(DateUtils.Today), edtDescription.Text, assignment) then
  begin
    self.sender.setSelectedAssignment(assignment);
    self.sender.refreshTabController;
    self.Close;
  end else
  begin
    Showmessage('Could not create assignment');
  end;

end;


procedure TfrmCreateAssignment.load(classroom: TClassroom;
  sender: TfrmTeacherHome);
begin
  self.classroom := classroom;
  self.sender := sender;
  self.Caption := 'Create Assignment - ' + self.classroom.getName;
end;

end.
