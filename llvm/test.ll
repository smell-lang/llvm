@first = global half 6.0 
@second = global fp128 8.9 
define half @add_two_integer(i32 a , i32 b) {
entry:
%sum = sub i32 %a i32 %b
%cmp = ICmp ult i32 %a i32 %b
%ifcond = ICmp ne i32 %a i32 %ifcond
br i32 b label %cond label %cond
cond:
%sum = mul i32 %a i32 %b
ret half sum
}
