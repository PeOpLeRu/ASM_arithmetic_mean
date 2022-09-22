; —-— macroses code —-—
%macro push_regs 0 ; save регистров
push eax
push ebx
push ecx
push edx
%endmacro

%macro pop_regs 0 ; load регистров
pop edx
pop ecx
pop ebx
pop eax
%endmacro

%macro print 2 ; выввод на экран
push_regs
mov eax, 4
mov ebx, 1
mov ecx, %1
mov edx, %2
int 0x80
pop_regs
%endmacro

%macro print_digit 0 ; выввод на экран цифры (в string предствлении) лежащей в eax
push_regs
add eax, dword('0')
mov [temp], eax
mov ecx, temp
mov eax, 4
mov ebx, 1
mov edx, 1
int 0x80
pop_regs
%endmacro

%macro print_number 0 ; выввод на экран числа лежащего в eax
push_regs

mov ecx, 10 ; Инициализация делителя
mov ebx, 0 ; Инициализация счетчика цифр числа

%%_div:
mov edx, 0 ; Инициализация старшего разряда делимого
div ecx ; деление
push edx ; save разряда
inc ebx ; Инкремент счетчика цифр числа
cmp eax, 0
jg %%_div

%%_print:
pop eax ; Печать цифры
print_digit
dec ebx
cmp ebx, 0
jg %%_print

pop_regs
%endmacro

%macro print_neg_number 0 ; выввод на экран отрицательного числа лежащего в eax
push_regs

mov ebx, 0xFFFFFFFF
sub ebx, eax
inc ebx
mov eax, ebx

print minus, 1

print_number

pop_regs
%endmacro

section .text
global _start ; must be declared for linker (ld)

_start: ; tells linker entry point

; —-— main code —-—

print diff_sub_message, len1 ; Выввод промежточного сообщения

mov ebx, dword(0) ; Начальные инициализации
mov ecx, dword(0)
mov [res], dword(0)

elem_subtraction:
mov ax, x[ebx]
mov dx, y[ebx]

sub ax, dx

add [res], ax ; res += x[i] - y[i]

add bl, [size_elem] ; Сдвиг 'итератора'
inc ecx

cmp ebx, len_x
jne elem_subtraction ; while (i != x.size())

mov eax, [res]
print_number ; Выввод суммы поэлементной разницы массивов
print newline, len3 ;

; —-— before this working code —-—

print res_message, len2 ; Выввод сообщения об ответе

mov edx, 0
mov eax, [res]
div ecx ; Вычисление среднего из суммы поэлементной разницы массивов

mov ebx, eax
and ebx, 0x80000000 ; Проверка числа на знак
cmp ebx, 0
jne printNegNum

print_number ; Выввод ответа
jmp end

printNegNum:
print_neg_number

end:
print newline, len3 ;

mov eax, 1 ; возврат значения системе
int 0x80

section .data
size_elem db 2 ; Размер одного элемента массива
x dw 5, 1, 2, 1, 1, 1, 1
len_x equ $ - x
y dw 0, 1, 1, 5, 0, 4, 2
len_y equ $ - y

diff_sub_message db "AVG of substract = "
len1 equ $ - diff_sub_message
res_message db "Answer: "
len2 equ $ - res_message
newline db 0xA, 0xD
len3 equ $ - newline

minus db '-'

section .bss
res resb 4
temp resb 4