(module
    (import "import" "debugPrint" (func $debugPrint (param i32 i32)))
    (import "import" "debugPrintI32" (func $debugPrintI32 (param i32)))
    (import "import" "debugPrintI64" (func $debugPrintI64 (param i64)))
    (import "import" "debugPrintF32" (func $debugPrintF32 (param f32)))
    (import "import" "debugPrintF64" (func $debugPrintF64 (param f64)))
    (import "import" "debugClear" (func $debugClear))
    (import "import" "debugSleep" (func $debugSleep (param i32)))
    (import "import" "debugRand" (func $debugRand (result f64)))

    (memory (export "memory") 1)
    (data (i32.const 0) "Hello World!")

    (func (export "print")
        (call $debugPrint (i32.const 0) (i32.const 12))
    )

   (func (export "clearPrint") (param i32 i32)
        (call $debugClear)
        (call $debugPrint (i32.const 0) (i32.const 12))
    )

    (func (export "printi32") (call $debugPrintI32 (i32.const 42)))
    (func (export "printi64") (call $debugPrintI64 (i64.const 42)))
    (func (export "printf32") (call $debugPrintF32 (f32.const 42)))
    (func (export "printf64") (call $debugPrintF64 (f64.const 42)))

    (func (export "sleep") (param i32)
        (call $debugSleep (local.get 0))
    )

    (func (export "printRand") (call $debugPrintF64 (call $debugRand)))
)
