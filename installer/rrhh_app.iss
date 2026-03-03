; Inno Setup script for RRHH App
; Build with:
;   iscc installer\rrhh_app.iss /DMyAppVersion=1.0.0 /DMyAppPublisher="RRHH App Team"

#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif

#ifndef MyAppPublisher
  #define MyAppPublisher "RRHH App Team"
#endif

#ifndef MyBuildDir
  #define MyBuildDir "..\build\windows\x64\runner\Release"
#endif

#ifndef MyOutputBaseFilename
  #define MyOutputBaseFilename "rrhh_app_setup_" + MyAppVersion
#endif

[Setup]
AppId={{5BC6F518-3DA1-4F90-8F5E-CFCA7AC262D8}
AppName=RRHH App
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\RRHH App
DefaultGroupName=RRHH App
DisableProgramGroupPage=yes
PrivilegesRequired=admin
OutputDir=..\dist
OutputBaseFilename={#MyOutputBaseFilename}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\rrhh_app.exe
SetupIconFile=..\windows\runner\resources\app_icon.ico

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Crear icono en el escritorio"; GroupDescription: "Accesos directos:"; Flags: unchecked

[Files]
Source: "{#MyBuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\windows\runner\resources\app_icon.ico"; DestDir: "{app}"; DestName: "app_icon_{#MyAppVersion}.ico"; Flags: ignoreversion

[InstallDelete]
Type: files; Name: "{commondesktop}\RRHH App.lnk"
Type: files; Name: "{autodesktop}\RRHH App.lnk"

[Icons]
Name: "{autoprograms}\RRHH App"; Filename: "{app}\rrhh_app.exe"; IconFilename: "{app}\app_icon_{#MyAppVersion}.ico"
Name: "{autodesktop}\RRHH App"; Filename: "{app}\rrhh_app.exe"; IconFilename: "{app}\app_icon_{#MyAppVersion}.ico"; Tasks: desktopicon

[Run]
Filename: "{app}\rrhh_app.exe"; Description: "Abrir RRHH App"; Flags: nowait postinstall skipifsilent

[Code]
function IsSameVersionInstalled(): Boolean;
var
  InstalledVersion: String;
  Key: String;
begin
  Result := False;
  Key := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{5BC6F518-3DA1-4F90-8F5E-CFCA7AC262D8}_is1';

  if RegQueryStringValue(HKLM64, Key, 'DisplayVersion', InstalledVersion) or
     RegQueryStringValue(HKLM32, Key, 'DisplayVersion', InstalledVersion) or
     RegQueryStringValue(HKCU, Key, 'DisplayVersion', InstalledVersion) then
  begin
    Result := (CompareText(InstalledVersion, '{#MyAppVersion}') = 0);
  end;
end;

function InitializeSetup(): Boolean;
begin
  if IsSameVersionInstalled() then
  begin
    MsgBox(
      'La version {#MyAppVersion} ya esta instalada.' + #13#10 +
      'Para actualizar, genera e instala una version superior (ej. 1.0.1).',
      mbInformation, MB_OK
    );
    Result := False;
    exit;
  end;

  Result := True;
end;
