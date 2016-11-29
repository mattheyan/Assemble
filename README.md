Assemble
========

A PowerShell Module for building a modules or single-file script from source (.ps1) scripts.

Exported Commands
-----------------

### Invoke-ScriptBuild

```
Invoke-ScriptBuild [-Name] <string> [[-SourcePath] <string[]>] [[-TargetPath] <string>]
    [[-OutputType] <string> {Auto | Module | Script}] [[-RequiredModules] <array>]
    [[-Exclude] <string[]>] [[-SymbolsToExport] <string[]>] [[-Flags] <string[]>]
    [-Force] [-Silent] [<CommonParameters>]
```

**Name** ( \*\*\* *required* \*\*\* )

Name of the module to build. This will determine the 'psd1' and 'psm1' file names.

**SourcePath**

Path(s) to the directory that contains the source files for the module or script
(e.g. '.\Scripts') and/or individual '.ps1' files. If not specified, the current
directory is used.

**TargetPath**

Path to the directory or file where the completed module or script will be
copied. If not specified, the current directory is used.

**OutputType**

Type type of file (module or script) to produce). If not specified, the type will
be inferred from the target path if a file path is given. The output type is
required if the target path is a directory or is omitted.

**RequiredModules**

The names of dependent modules to validate (if generating a module). If a module
with the specified name has not already been imported, attempts to import the
module by name from a global location (i.e. PSModulePath).

**Exclude**

A list of files (or wildcard patterns) in the source directory to exclude.

**SymbolsToExport**

A list of symbols to export (if generating a module). If not specified, then all
functions are exported.

**Flags**

Define one or more flags to be used by the preprocessor.

**Force**

If the target module file(s) already exist, overwrite it with the result.

**Silent**

Avoid printing status information to the console host.
