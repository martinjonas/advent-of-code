#lang racket

(define file-name "input")
(define input (map string-split (file->lines file-name)))

(define op-map (make-immutable-hash
                (list (cons "inc" +)
                      (cons "dec" -)
                      (cons "<" <)
                      (cons ">" >)
                      (cons "==" =)
                      (cons ">=" >=)
                      (cons "<=" <=)
                      (cons "!=" (negate =)))))

(define (instruction-satisfied? instruction register-values)
  (match-define (list _ _ _ _ arg op val) instruction)
  ((hash-ref op-map op) (hash-ref register-values arg 0) (string->number val)))

(define (apply-instruction instruction register-values)
  (match-define (list arg op val _ _ _ _) instruction)
  (define result ((hash-ref op-map op) (hash-ref register-values arg 0) (string->number val)))
  (hash-set register-values arg result))

(define (run-instruction instruction register-values)
  (if (instruction-satisfied? instruction register-values) (apply-instruction instruction register-values) register-values))

(define (max-val h) (foldl max 0 (hash-values h)))

(define (run-program instructions)
  (for/fold ([register-values (make-immutable-hash)]
             [max-register 0])
            ([instruction instructions])
    (define result (run-instruction instruction register-values))
    (values result (max max-register (max-val result))
)))

(define-values (result max-register) (run-program input))

(max-val result)
max-register
