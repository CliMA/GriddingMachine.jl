program gm_download
  use iso_fortran_env, only: error_unit
  character(4096) :: u, o, cmd
  integer :: n, stat
  if (command_argument_count() /= 2) then; write(error_unit,*) 'usage: gm_download URL OUTPUT'; stop 2; end if
  call get_command_argument(1,u); call get_command_argument(2,o)
  cmd = 'python3 clients/download.py --url "'//trim(u)//'" --output "'//trim(o)//'"'
  call execute_command_line(trim(cmd), exitstat=stat); if (stat /= 0) stop stat
end program gm_download
