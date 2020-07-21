unit Un_Principal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SynEdit,
  SynHighlighterPas, uPSComponent, uPSRuntime,

  Un_Evento,

  uPSCompiler,
  uPSC_std,      uPSR_std,
  uPSC_Classes,  uPSR_classes

  ;

type

  { TForm1 }

  TForm1 = class(TForm)
    btExecutar: TButton;
    btExecutarDelphi: TButton;
    btSalvar: TButton;
    MemoScript: TSynEdit;
    Scripter: TPSScript;
    SynPasSyn1: TSynPasSyn;
    procedure btExecutarClick(Sender: TObject);
    procedure btSalvarClick(Sender: TObject);
    procedure ScripterCompile(Sender: TPSScript);
    procedure ScripterExecImport(Sender: TObject; se: TPSExec;
      x: TPSRuntimeClassImporter);
  private
     function arquivo: String;
     procedure ProcedureDoEvento( txt: String );
  public
     constructor Create(TheOwner: TComponent); override;
  end;

var
  Form1: TForm1;

implementation


procedure TCLASSEVENTO_R(Self: TClassEvento; var T: TEvento);
begin
   T := Self.Evento;
end;
procedure TCLASSEVENTO_W(Self: TClassEvento; const T: TEvento);
begin
   Self.Evento := T;
end;


{$R *.lfm}

{ TForm1 }

procedure TForm1.btExecutarClick(Sender: TObject);
begin
   Scripter.Script.Text := MemoScript.Lines.Text;
   if Scripter.compile then begin
      Scripter.execute;
   end else begin
      showmessage(String(Scripter.CompilerErrorToStr(0)));
   end;
end;

procedure TForm1.btSalvarClick(Sender: TObject);
begin
   MemoScript.Lines.SaveToFile( arquivo );
   // MemoScript.MarkModifiedLinesAsSaved;
end;

procedure TForm1.ScripterCompile(Sender: TPSScript);
begin
   sender.AddFunction(@ExtractFileExt, 'function ExtractFileExt(const FileName: string): string;');
   sender.AddFunction(@ExtractFileName,'function ExtractFileName(const FileName: string): string;');
   sender.AddFunction(@ShowMessage,    'procedure ShowMessage(const Msg: string);');

   SIRegister_Std(Sender.Comp);
   SIRegister_Classes(Sender.Comp,true);

   Sender.Comp.AddTypeS('TEvento', 'procedure( txt: String ) of object;');


   with Sender.Comp.AddClassN(Sender.Comp.FindClass('TComponent'), 'TClassEvento') do begin
      RegisterProperty('Evento',  'TEvento',      iptrw);
      RegisterMethod('procedure Executar;');
   end;
end;

procedure TForm1.ScripterExecImport(Sender: TObject; se: TPSExec;
  x: TPSRuntimeClassImporter);
begin
   RIRegister_Std(x);
   RIRegister_Classes(x,true);

   with X.Add(TClassEvento) do begin
      RegisterPropertyHelper(@TCLASSEVENTO_R, @TCLASSEVENTO_W, 'Evento');
      RegisterMethod(@TClassEvento.Executar, 'Executar');
   end;
end;

function TForm1.arquivo: String;
begin
   Result := ExtractFilePath( Application.ExeName ) + 'script.pas';
end;

procedure TForm1.ProcedureDoEvento(txt: String);
begin
   ShowMessage( 'Dentro do Delphi: ' + txt );
end;

constructor TForm1.Create(TheOwner: TComponent);
begin
   inherited Create(TheOwner);

   SynPasSyn1.StringAttri.Foreground  := clMaroon;
   SynPasSyn1.CommentAttri.Foreground := clGrayText;
   SynPasSyn1.KeyAttri.Foreground     := clBlue;
   SynPasSyn1.NumberAttri.Foreground  := clGreen;

  //  Attri.Foreground   := clGreen;

   if FileExists( arquivo ) then begin
      MemoScript.Lines.LoadFromFile( arquivo );
   end else begin
      MemoScript.Lines.Add( 'begin');
      MemoScript.Lines.Add( '');
      MemoScript.Lines.Add( 'end.');
   end;
end;

end.

