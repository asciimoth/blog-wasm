(module
	(func (export "calculateTheAnswer") (result i32)
		;; 21/5*10 + 8%3
		(i32.add
			(i32.mul
				(i32.div_s (i32.const 21) (i32.const 5))
				(i32.const 10)
			)
			(i32.rem_u (i32.const 8) (i32.const 3))
		)
	)
)
