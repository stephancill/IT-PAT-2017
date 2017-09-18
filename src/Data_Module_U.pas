unit Data_Module_U;

interface

uses
  SysUtils, Classes, DB, ADODB;

type
  Tdata_module = class(TDataModule)
    connection: TADOConnection;
    qry: TADOQuery;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  data_module: Tdata_module;

implementation

{$R *.dfm}

end.
