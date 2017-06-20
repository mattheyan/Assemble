Assemble
========

A PowerShell Module for building a modules or single-file script from source (.ps1) scripts.

Exported Commands
-----------------

### Invoke-ScriptBuild

```

**Module Output:**

Invoke-ScriptBuild [-Name] <string> [[-SourcePath] <string[]>] [[-TargetPath] <string>]
    [-DependenciesToValidate <array>] [-Exclude <string[]>] [-SymbolsToExport <string[]>]
    [-OutputMode <string> {RawContent | WrapFunction | AutoDetect}] [-DefinedSymbols <string[]>]
    [-Flags <string[]>] [-Force] [-Silent] [<CommonParameters>]

**Module Output (no export declarations):**

Invoke-ScriptBuild [-Name] <string> [[-SourcePath] <string[]>] [[-TargetPath] <string>]
    [-DependenciesToValidate <array>] [-Exclude <string[]>] [-SuppressSymbolExport]
    [-OutputMode <string> {RawContent | WrapFunction | AutoDetect}] [-DefinedSymbols <string[]>]
    [-Flags <string[]>] [-Force] [-Silent] [<CommonParameters>]

**Script Output:**

Invoke-ScriptBuild [-Name] <string> [[-SourcePath] <string[]>] [[-TargetPath] <string>]
    -AsScript [-DependenciesToValidate <array>] [-Exclude <string[]>]
    [-OutputMode <string> {RawContent | WrapFunction | AutoDetect}] [-DefinedSymbols <string[]>]
    [-Flags <string[]>] [-Force] [-Silent] [<CommonParameters>]

**Legacy Parameters:**

Invoke-ScriptBuild [-Name] <string> [[-SourcePath] <string[]>] [[-TargetPath] <string>]
    -OutputType <string> {Auto | Module | Script} [-DependenciesToValidate <array>]
    [-Exclude <string[]>] [-SymbolsToExport <string[]>] 
    [-OutputMode <string> {RawContent | WrapFunction | AutoDetect}] [-DefinedSymbols <string[]>]
    [-Flags <string[]>] [-Force] [-Silent] [<CommonParameters>]

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

**OutputType (Deprecated)**

Type type of file (module or script) to produce). If not specified, the type will
be inferred from the target path if a file path is given. The output type is
required if the target path is a directory or is omitted.

**AsScript**

If specified, a single script file will be produced rather than a module file.

**DependenciesToValidate**

The names of dependent modules to validate (if generating a module). If a module
with the specified name has not already been imported, attempts to import the
module by name from a global location (i.e. PSModulePath).

**DefinedSymbols**

Optional list of "symbols" that can be referenced in the source as script files.
This may be useful if you have multiple modules with invoke-able script source,
where one module references the other. Scripts in the first module can directly
reference scripts in the second module and compile to a function call.

**Exclude**

A list of files (or wildcard patterns) in the source directory to exclude.

**SuppressSymbolExport**

Don't declare any exported module members. This has the effect of exporting
everything (if the module manifest declares export '*'), OR, allows you to specify
your exports in a "\_\_final\_\_.ps1" file.

**SymbolsToExport**

A list of symbols to export (if generating a module). If not specified, then all
functions are exported.

**OutputMode**

Determines the way that script files' contents are written to the generated module.
Typically functions included in modules are written as '.ps1' files that declare
a single function of the same name as the file. However, you may want to write
your script files to be executable instead. By default, Assemble will detect whether
the first line in your script is "function Verb-Noun {" (matching the name of the file)
in order to determine which approach is taken. However, you can specify the output mode
that you want in case the automatic behavior results in unexpected behavior.

**Flags**

Define one or more flags to be used by the preprocessor.

**Force**

If the target module file(s) already exist, overwrite it with the result.

**Silent**

Avoid printing status information to the console host.
