Either use -mstackrealign compiler flag for the whole project or add

__attribute__((force_align_arg_pointer)) before each SSE using function.
If stack is not 16 bytes aligned, dll will crash randomly.