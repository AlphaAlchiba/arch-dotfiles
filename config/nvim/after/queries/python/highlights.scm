; extends

; Imported names in `from x import y` — captured as @module.import so they
; can be colored lavender like constructors (a class reference is lavender
; whether imported or instantiated), distinct from the module path
; (django.db -> @module, salmon).
(import_from_statement
  name: (dotted_name (identifier) @module.import))

(import_from_statement
  name: (aliased_import
    name: (dotted_name (identifier) @module.import)
    alias: (identifier) @module.import))

; Attribute objects (models in models.CharField) — lavender like imported
; names and constructors, so module/class references read consistently
; whether imported or used. self/cls keep their builtin color.
((attribute
  object: (identifier) @module.import)
  (#lua-match? @module.import "^[%l_].*$")
  (#not-eq? @module.import "self")
  (#not-eq? @module.import "cls"))

; Class-body plain assignments (title = ...) — base code, keep the variable
; color instead of the golden attribute color.
((class_definition
  body: (block
    (expression_statement
      (assignment
        left: (identifier) @variable))))
  (#lua-match? @variable "^[%l_].*$"))

; Class names and superclasses are captured as @type.definition so the
; @type naming-convention capture doesn't claim them; both are golden
; italic in the palette, like type annotations.
(class_definition
  name: (identifier) @type.definition)

(class_definition
  superclasses: (argument_list
    (identifier) @type.definition))

(class_definition
  superclasses: (argument_list
    (attribute
      attribute: (identifier) @type.definition)))

; Guarantee constructor calls (models.CharField(...)) render as @constructor
; — appended last so it wins over @type/@variable regardless of query order.
((call
  function: (attribute
    attribute: (identifier) @constructor))
  (#lua-match? @constructor "^%u"))