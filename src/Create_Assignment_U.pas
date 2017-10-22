unit Create_Assignment_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Utilities_U, Classroom_U, ComCtrls, DateUtils, Assignment_U;

type
  TfrmCreateAssignment = class(TForm)
    edtTitle: TEdit;
    edtDescription: TRichEdit;
    btnCreate: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
  private
    { Private declarations }
    classroom: TClassroom;
  public
    { Public declarations }
    procedure setClassroom(classroom: TClassroom);
  end;

var
  frmCreateAssignment: TfrmCreateAssignment;

implementation

uses Teacher_Home_U;

{$R *.dfm}

{ TForm1 }

procedure TfrmCreateAssignment.btnCreateClick(Sender: TObject);
var
  assignment: TAssignment;
begin
  Utilities.createAssignment(self.classroom, edtTitle.Text, datetostr(DateUtils.Today), edtDescription.Text, assignment);
  frmTeacherHome.setSelectedAssignment(assignment);
  self.Hide;
  frmTeacherHome.refreshTabController;
  frmTeacherHome.Show;
end;

procedure TfrmCreateAssignment.FormActivate(Sender: TObject);
begin
  self.Caption := 'Create Assignment - ' + self.classroom.getName;
end;

procedure TfrmCreateAssignment.setClassroom(classroom: TClassroom);
begin
  self.classroom := classroom;
end;

end.
