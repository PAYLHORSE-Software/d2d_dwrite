AT_COMPILE_TIME :: true;

PREFIXES_FOR_TYPES_TO_OMIT :: string.[
    "__REQUIRED_",
    "LP",
    "IID_",
    "__MIDL_",
];

#if AT_COMPILE_TIME {
    #run,stallable {
        set_build_options_dc(.{do_output=false});
        root_options := get_build_options();
        args := root_options.compile_time_command_line;
        if !generate_bindings(args) {
            compiler_set_workspace_status(.FAILED);
        }
    }
} else {
    #import "System";

    main :: () {

        set_working_directory(path_strip_filename(get_path_of_running_executable()));
        args := get_command_line_arguments();
        if !generate_bindings(args) {
            exit(1);
        }
    }
}

generate_bindings :: (args: [] string) -> bool {

    opts: Generate_Bindings_Options;
    {
        using opts;

	array_add(*libnames, "d2d1.dll");

	array_add(*source_files, "d2d1_3.h");
	array_add(*source_files, "dwrite_3.h");

	system_paths :: string.[
	    "d2d1.h",
	    "d2d1_1.h",
	    "d2d1_2.h",
	    "d2d1_3.h",
	    "dwrite.h",
	    "dwrite_1.h",
	    "dwrite_2.h",
	    "dwrite_3.h",
	    "dcommon.h",
	    "d2d1effects.h",
	    "d2d1effects_1.h",
	    "d2d1effects_2.h",
	    "d2dbasetypes.h",
	    "d2d1svg.h",
	];

        array_add(*path_fragments_to_treat_as_non_system_paths, ..system_paths);
	
        array_add(*extra_clang_arguments, "-x", "c++", "-DWIN32_LEAN_AND_MEAN");
        log_unsupported = true;

        // Any extra code to include before or after the generated code.
        header = HEADER;
        footer = FOOTER;

        visitor = d2d_visitor;
    }

    return generate_bindings(opts, "d2d_dwrite_bindings.jai");
}

d2d_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    if !parent_decl {
        for PREFIXES_FOR_TYPES_TO_OMIT {
            if begins_with(decl.name, it) {
                decl.decl_flags |= .OMIT_FROM_OUTPUT;
                return .STOP;
            }
        }
    }

    return .RECURSE;
}

#scope_file

#import "Basic";
#import "Bindings_Generator";
#import "Compiler";
#import "File";
#import "String";

// DECLARATIONS_TO_OMIT :: string.[
// ];

HEADER :: #string DONE
//  ---------------------------------
// | Direct2D & DirectWrite BINDINGS |
//  ---------------------------------
DONE

FOOTER :: #string DONE
#import "Windows";
#import "dxgi";

// Win32 additions:

CLSID :: GUID;
// PSTR :: LPSTR;
PCWSTR :: LPCWSTR;
COLORREF :: DWORD;
LONG :: s32;
IStream :: IUnknown;

FONTSIGNATURE :: struct {
    fsUsb: [4] DWORD;
    fsCsb: [2] DWORD;
}

LOGFONTW :: struct {
  lfHeight: s32;
  lfWidth: s32;
  lfEscapement: s32;
  lfOrientation: s32;
  lfWeight: LONG;
  lfItalic: u8;
  lfUnderline: u8;
  lfStrikeOut: u8;
  lfCharSet: u8;
  lfOutPrecision: u8;
  lfClipPrecision: u8;
  lfQuality: u8;
  lfPitchAndFamily: u8;
  lfFaceName: [32] u16;
}

LOGFONT :: LOGFONTW;

DONE
