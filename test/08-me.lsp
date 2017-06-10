(define foo (fun () 0))
(print-num foo)

(define x 1)
(define bar (fun (x y) (+ x y)))
(print-num (bar 2 3))
(print-num x)

