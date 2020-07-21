unit Un_Evento;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

type

  TEvento = procedure( txt: String ) of object;

  { TClassEvento }

  TClassEvento = class( TComponent )
  private
     FEvento: TEvento;
  public
     property Evento: TEvento read FEvento write FEvento;
     procedure Executar;
  end;


implementation

{ TClassEvento }

procedure TClassEvento.Executar;
begin
  ShowMessage( 'Cliquei no Executar' );
  if Assigned(FEvento) then begin
     FEvento( 'Olá Mundo' );
  end;
end;

end.

