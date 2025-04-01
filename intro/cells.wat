(module
    (import "debug" "print" (func $debugPrint (param i32 i32)))
    (import "debug" "clear" (func $debugClear))
    (import "debug" "sleep" (func $debugSleep (param i32)))
    (import "debug" "rand" (func $debugRand (result f64)))

    (memory (export "memory") 1)

    (table (export "table") 4 funcref)
    ;; Rules
    (elem (i32.const 0) func $b3s23)
    (elem (i32.const 1) func $b1s012345678)
    ;; Neighborhoods
    (elem (i32.const 2) func $Moore)
    (elem (i32.const 3) func $VonNeumann)

    (global $cols (mut i32) (i32.const 0))
    (global $rows (mut i32) (i32.const 0))
    (global $frameSize (mut i32) (i32.const 0))
    ;; frame1 (0, frameSize]
    ;; frame1 (frameSize, frameSize*2]
    (global $frame (mut i32) (i32.const 0))
    (global $output (mut i32) (i32.const 0))
    (global $rule (mut i32) (i32.const 0))
    (global $neighborhood (mut i32) (i32.const 0))

    (type $neighborhoodType (func
        (param $upLeft i32) (param $up i32) (param $upRight i32)
        (param $right i32) (param $downRight i32) (param $down i32)
        (param $downLeft i32) (param $left i32)
        (result i32)
    ))

    (type $ruleType (func (param $self i32) (param $neigbours i32) (result i32)))

    (func (export "init")
        (param $cols i32) (param $rows i32)
        (param $rule i32) (param $neighborhood i32)
        (global.set $cols (local.get $cols))
        (global.set $rows (local.get $rows))
        (global.set $rule (local.get $rule))
        (global.set $neighborhood (local.get $neighborhood))
        (global.set $frameSize (i32.mul (local.get $cols) (local.get $rows)))
        (global.set $frame (i32.const 0))
        (global.set $output (i32.mul (global.get $frameSize) (i32.const 2)))
        ;; Clean frames
        (memory.fill
            (i32.const 0) (i32.const 0) (global.get $output)
        )
    )

    (func $another (export "anotherFrame") (result i32)
        (if (result i32) (i32.eq (global.get $frame) (global.get $frameSize))
            (then (i32.const 0))
            (else (global.get $frameSize))
        )
    )

    (func $swap (export "swapFrames")
        (global.set $frame (call $another))
    )

    (func $checkOOB (export "checkOOB")
        (param $col i32) (param $row i32) (result i32)
        (i32.lt_s (local.get $col) (i32.const 0))
        (i32.lt_s (local.get $row) (i32.const 0))
        (i32.ge_s (local.get $col) (global.get $cols))
        (i32.ge_s (local.get $row) (global.get $rows))
        (i32.or) (i32.or) (i32.or)
    )

    (func $setCell (export "setCell")
        (param $col i32) (param $row i32) (param $val i32) (param $frame i32)
        ;; Check out of bounds
        (if (call $checkOOB (local.get $col) (local.get $row)) (then return))
        ;; Set
        (i32.store8
            (i32.add
                (local.get $frame)
                (i32.add
                    (i32.mul (local.get $row) (global.get $cols))
                    (local.get $col)
                )
            )
            (local.get $val)
        )
    )

    (func $getCell (export "getCell")
        (param $col i32) (param $row i32) (param $frame i32) (result i32)
        ;; Check out of bounds
        (if (call $checkOOB (local.get $col) (local.get $row))
            (then (return (i32.const 0)))
        )
        ;; Get
        (i32.load8_u
            (i32.add
                (local.get $frame)
                (i32.add
                    (i32.mul (local.get $row) (global.get $cols))
                    (local.get $col)
                )
            )
        )
    )

    (func $raise (export "raise") (param $col i32) (param $row i32)
        (call $setCell
            (local.get $col) (local.get $row) (i32.const 1) (global.get $frame)
        )
    )

    (func $drop (export "drop") (param $col i32) (param $row i32)
        (call $setCell
            (local.get $col) (local.get $row) (i32.const 0) (global.get $frame)
        )
    )

    (func (export "seedHabr")
        (local $col i32)
        (local $row i32)
        (local.set $col (i32.div_s (global.get $cols) (i32.const 2)))
        (local.set $row (i32.div_s (global.get $rows) (i32.const 2)))
        (;
            0123456789AB
           0+ +    +
           1+++ ++ ++ ++
           2+ + ++ ++ +

           0:0 0:1 0:2 1:1 2:0 2:1 2:2 4:1 4:2 5:1 5:2 7:0 7:1 7:2 8:1 8:2
           10:1 10:2 11:1
        ;)
        (call $raise
            (i32.add (local.get $col) (i32.const 0))
            (i32.add (local.get $row) (i32.const 0))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 0))
            (i32.add (local.get $row) (i32.const 1))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 0))
            (i32.add (local.get $row) (i32.const 2))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 1))
            (i32.add (local.get $row) (i32.const 1))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 2))
            (i32.add (local.get $row) (i32.const 0))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 2))
            (i32.add (local.get $row) (i32.const 1))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 2))
            (i32.add (local.get $row) (i32.const 2))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 4))
            (i32.add (local.get $row) (i32.const 1))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 4))
            (i32.add (local.get $row) (i32.const 2))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 5))
            (i32.add (local.get $row) (i32.const 1))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 5))
            (i32.add (local.get $row) (i32.const 2))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 7))
            (i32.add (local.get $row) (i32.const 0))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 7))
            (i32.add (local.get $row) (i32.const 1))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 7))
            (i32.add (local.get $row) (i32.const 2))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 8))
            (i32.add (local.get $row) (i32.const 1))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 8))
            (i32.add (local.get $row) (i32.const 2))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 10))
            (i32.add (local.get $row) (i32.const 1))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 10))
            (i32.add (local.get $row) (i32.const 2))
        )
        (call $raise
            (i32.add (local.get $col) (i32.const 11))
            (i32.add (local.get $row) (i32.const 1))
        )
    )

    (func (export "seedGlider")
        (call $raise (i32.const 1) (i32.const 0))
        (call $raise (i32.const 2) (i32.const 1))
        (call $raise (i32.const 0) (i32.const 2))
        (call $raise (i32.const 1) (i32.const 2))
        (call $raise (i32.const 2) (i32.const 2))
    )

    (func (export "seedPoint")
        (call $raise
            (i32.div_s (global.get $cols) (i32.const 2))
            (i32.div_s (global.get $rows) (i32.const 2))
        )
    )

    (func (export "seedRandom")
        (local $end i32)
        (local $off i32)
        (local.set $off (global.get $frame))
        (local.set $end (i32.add
            (global.get $frame)
            (global.get $frameSize)
        ))
        (loop $loop
            (if (f64.le (f64.const 0.5) (call $debugRand)) (then
                (i32.store8 (local.get $off) (i32.const 1))
            ))
            (local.tee $off (i32.add (local.get $off) (i32.const 1)))
            (br_if $loop (i32.ne (local.get $end)))
        )
    )

    ;; Aka Conway's Game Of Life
    (func $b3s23 (export "b3s23")
        ;; $rule interface
        (param $self i32) (param $neigbours i32) (result i32)
        (if (result i32) (local.get $self)
            (then
                (i32.or
                    (i32.eq (local.get $neigbours) (i32.const 2))
                    (i32.eq (local.get $neigbours) (i32.const 3))
                )
            )
            (else
                (i32.eq (local.get $neigbours) (i32.const 3))
            )
        )
    )

    ;; No death
    (func $b1s012345678 (export "b1s012345678")
        ;; $rule interface
        (param $self i32) (param $neigbours i32) (result i32)
        (if (result i32) (local.get $self)
            (then
                (i32.const 1)
            )
            (else
                (i32.eq (local.get $neigbours) (i32.const 1))
            )
        )
    )

    (func $Moore (export "Moore")
        ;; $neighborhood interface
        (param $upLeft i32) (param $up i32) (param $upRight i32)
        (param $right i32) (param $downRight i32) (param $down i32)
        (param $downLeft i32) (param $left i32)
        (result i32)

        (local.get $upLeft)
        (local.get $up)
        (local.get $upRight)
        (local.get $right)
        (local.get $downRight)
        (local.get $down)
        (local.get $downLeft)
        (local.get $left)

        (i32.add) (i32.add) (i32.add) (i32.add)
        (i32.add) (i32.add) (i32.add)
    )

    (func $VonNeumann (export "VonNeumann")
        ;; $neighborhood interface
        (param $upLeft i32) (param $up i32) (param $upRight i32)
        (param $right i32) (param $downRight i32) (param $down i32)
        (param $downLeft i32) (param $left i32)
        (result i32)

        (local.get $up)
        (local.get $right)
        (local.get $down)
        (local.get $left)

        (i32.add) (i32.add) (i32.add)
    )

    ;; 0 -> " "
    ;; 1 -> "+"
    (func $toChar (export "toChar") (param i32) (result i32)
        (i32.add (i32.const 32) (i32.mul (i32.const 11) (local.get 0)))
    )

    (func $render (export "render") (result i32 i32) ;; From To
        (local $end i32)
        (local $inrow i32)
        (local $src i32)
        (local $dst i32)
        (local.set $src (global.get $frame))
        (local.set $dst (global.get $output))
        (local.set $end (i32.add
            (global.get $frame)
            (global.get $frameSize)
        ))
        (local.set $inrow (i32.const 0))
        (loop $loop
            (block $block
                (i32.store8 (local.get $dst)
                    (call $toChar (i32.load8_u (local.get $src)))
                )
                (local.set $dst (i32.add (local.get $dst) (i32.const 1)))
                (local.set $src (i32.add (local.get $src) (i32.const 1)))
                (local.set $inrow (i32.add (local.get $inrow) (i32.const 1)))
                (if
                    (i32.eq (local.get $inrow) (global.get $cols))
                    (then
                        (i32.store8 (local.get $dst) (i32.const 10)) ;; \n
                        (local.set $dst (i32.add (local.get $dst) (i32.const 1)))
                        (local.set $inrow (i32.const 0))
                    )
                )
                (br_if $block (i32.eq (local.get $end) (local.get $src)))
                (br $loop)
            )
        )
        (global.get $output) (local.get $dst)
    )

    (func $getNeigbours (export "getNeigbours")
        (param $col i32) (param $row i32) (result i32)
        (call_indirect (type $neighborhoodType)
            (call $getCell 
                (i32.add (local.get $col) (i32.const -1))
                (i32.add (local.get $row) (i32.const -1))
                (global.get $frame)
            )
            (call $getCell 
                (i32.add (local.get $col) (i32.const 0))
                (i32.add (local.get $row) (i32.const -1))
                (global.get $frame)
            )
            (call $getCell 
                (i32.add (local.get $col) (i32.const 1))
                (i32.add (local.get $row) (i32.const -1))
                (global.get $frame)
            )
            (call $getCell 
                (i32.add (local.get $col) (i32.const 1))
                (i32.add (local.get $row) (i32.const 0))
                (global.get $frame)
            )
            (call $getCell 
                (i32.add (local.get $col) (i32.const 1))
                (i32.add (local.get $row) (i32.const 1))
                (global.get $frame)
            )
            (call $getCell 
                (i32.add (local.get $col) (i32.const 0))
                (i32.add (local.get $row) (i32.const 1))
                (global.get $frame)
            )
            (call $getCell 
                (i32.add (local.get $col) (i32.const -1))
                (i32.add (local.get $row) (i32.const 1))
                (global.get $frame)
            )
            (call $getCell 
                (i32.add (local.get $col) (i32.const -1))
                (i32.add (local.get $row) (i32.const 0))
                (global.get $frame)
            )
            (global.get $neighborhood)
        )
    )

    (func $show (export "show")
        (call $debugPrint (call $render))
    )

    (func $step (export "step")
        (local $col i32)
        (local $row i32)
        (local $next i32)
        (local.set $next (call $another))
        (local.set $row (i32.const 0))
        (loop $rloop
            (local.set $col (i32.const 0))
            (loop $cloop
                (call $setCell
                    (local.get $col)
                    (local.get $row)
                    (call_indirect (type $ruleType)
                        (call $getCell
                            (local.get $col)
                            (local.get $row)
                            (global.get $frame)
                        )
                        (call $getNeigbours (local.get $col) (local.get $row))
                        (global.get $rule)
                    )
                    (local.get $next)
                )
                (local.set $col (i32.add (local.get $col) (i32.const 1)))
                (br_if $cloop (i32.lt_s (local.get $col) (global.get $cols)))
            )
            (local.set $row (i32.add (local.get $row) (i32.const 1)))
            (br_if $rloop (i32.lt_s (local.get $row) (global.get $rows)))
        )
        ;; Swap frames
        (call $swap)
    )

    (func (export "run") (param $sleep i32)
        (loop $loop
            (call $debugClear)
            (call $show)
            (call $step)
            (call $debugSleep (local.get $sleep))
            (br $loop)
        )
    )
)
