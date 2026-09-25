program gm_download
  use iso_fortran_env, only: error_unit
  character(4096) :: u, o, cmd
  integer :: n, stat
  if (command_argument_count() /= 2) then; write(error_unit,*) 'usage: gm_download URL OUTPUT'; stop 2; end if
  call get_command_argument(1,u); call get_command_argument(2,o)
  cmd = 'python3 clients/download.py --url '//shell_quote(trim(u))//' --output '//shell_quote(trim(o))
  call execute_command_line(trim(cmd), exitstat=stat); if (stat /= 0) stop stat
contains
  function shell_quote(value) result(quoted)
    character(len=*), intent(in) :: value
    character(len=:), allocatable :: quoted
    integer :: i, j, extra
    extra = 0
    do i = 1, len(value)
      if (value(i:i) == "'") extra = extra + 4
    end do
    allocate(character(len=len(value)+extra+2) :: quoted)
    quoted = "'"
    j = 2
    do i = 1, len(value)
      if (value(i:i) == "'") then
        quoted(j:j+3) = "'\''"
        j = j + 4
      else
        quoted(j:j) = value(i:i)
        j = j + 1
      end if
    end do
    quoted(j:j) = "'"
  end function shell_quote
end program gm_download
