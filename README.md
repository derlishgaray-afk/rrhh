# rrhh_app

Aplicacion RRHH construida con Flutter.

## Generar instalable para Windows

Prerequisitos:

- Flutter instalado y en PATH.
- (Opcional) Inno Setup instalado y `iscc` en PATH para generar `.exe` instalador.

Comando:

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\build_windows_installer.ps1
```

Resultado:

- Si hay Inno Setup: genera `dist\rrhh_app_setup_<version>.exe`
- Si no hay Inno Setup: genera `dist\rrhh_app_windows_portable_<version>.zip`

Opcional (forzar version/publisher):

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\build_windows_installer.ps1 -Version 1.0.0 -Publisher "Mi Empresa"
```
