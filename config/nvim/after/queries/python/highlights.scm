; extends

; Imported names in `from x import y` — captured as @module.import so they
; can be colored golden (see lua/custom/highlights/palettes/aura-dracula-spirit.lua),
; distinct from the module path (django.db -> @module, salmon).
(import_from_statement
  name: (dotted_name (identifier) @module.import))

(import_from_statement
  name: (aliased_import
    name: (dotted_name (identifier) @module.import)
    alias: (identifier) @module.import))

; Attribute objects (models in models.CharField) — golden like the import,
; so module references are easy to spot. self/cls keep their builtin color.
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

; Class names and superclasses stay upright — only type annotations are
; italic (the @type naming-convention capture would italicize them).
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