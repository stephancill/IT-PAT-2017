unit ApplicationDelegate_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TfrmApplicationDelegate = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure applicationReady;
  end;

var
  frmApplicationDelegate: TfrmApplicationDelegate;

implementation

uses Authenticate_U, Create_Assignment_U, Teacher_Home_U;

{$R *.dfm}

procedure TfrmApplicationDelegate.applicationReady;
begin
  self.Hide;
  frmAuthenticate.Show;
end;


procedure TfrmApplicationDelegate.FormCreate(Sender: TObject);
begin
  self.Hide;
end;

end.
