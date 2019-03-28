use "example.sml";
              
fun getBinary (ast.Module x) = (#modulename(x))

val ff = (getBinary defaultModule)

val convert = _import "helper" : string -> int;
val _ = convert ff;

