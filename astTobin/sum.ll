; ModuleID = 'sum.bc'
source_filename = "dd"

@first = external global float
@second = external global i32

define void @add_two_integer(i32, i32) {
entry:
  %sum = add i32 %0, %1
  %sm = sub i32 %sum, %0
  br label %entry1

entry1:                                           ; preds = %entry
  %cmp = icmp sge i32 %sum, %1
  br i1 %cmp, label %entry2, label %entry3

entry2:                                           ; preds = %entry1
  %son = add i32 %0, %1
  ret i32 %son

entry3:                                           ; preds = %entry1
  %soj = alloca i32
  store i32 3, i32* %soj
  ret i32* %soj
}

define float @add_two_integer1(i32, i32) {
entry:
  %sum = add i32 %0, %1
  %sm = sub i32 %sum, %0
  br label %entry
}
