program gm_download
  use iso_fortran_env, only: error_unit
  character(4096) :: u, o, cmd, python
  character(64) :: os_name
  integer :: stat, env_stat
  logical :: windows
  if (command_argument_count() /= 2) then; write(error_unit,*) 'usage: gm_download URL OUTPUT'; stop 2; end if
  call get_command_argument(1,u); call get_command_argument(2,o)
  call get_environment_variable('OS', os_name, status=env_stat)
  windows = env_stat == 0 .and. trim(os_name) == 'Windows_NT'
  call get_environment_variable('GM_PYTHON', python, status=env_stat)
  if (env_stat /= 0 .or. len_trim(python) == 0) then
    if (windows) then; python = 'python'; else; python = 'python3'; end if
  end if
  if (windows) then
    if (index(trim(python)//trim(u)//trim(o), '"') /= 0) then
      write(error_unit,*) 'double quotes are not supported in arguments'; stop 2
    end if
    cmd = '""'//trim(python)//'" "clients/download.py" --url "'//trim(u)//'" --output "'//trim(o)//'""'
  else
    if (index(trim(python)//trim(u)//trim(o), "'") /= 0) then
      write(error_unit,*) 'single quotes are not supported in arguments'; stop 2
    end if
    cmd = "'"//trim(python)//"' 'clients/download.py' --url '"//trim(u)//"' --output '"//trim(o)//"'"
  end if
  call execute_command_line(trim(cmd), exitstat=stat)
  if (stat /= 0) then; write(error_unit,*) 'Python downloader failed'; stop 1; end if
end program gm_download
