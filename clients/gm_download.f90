program gm_download
  use iso_fortran_env, only: error_unit
  implicit none
  character(:), allocatable :: python, script, command, value, executable, bootstrap
  character(1024) :: message
  integer :: i, first, exit_status, command_status
  logical :: windows, found

  ! Read dynamic-length strings so valid paths and options are never silently truncated.
  windows = environment('OS') == 'Windows_NT'
  python = environment('GM_PYTHON')
  if (len(python) == 0) then
    if (windows) then
      python = 'python'
    else
      python = 'python3'
    end if
  end if
  executable = argument(0)
  script = environment('GM_DOWNLOADER')
  if (len(script) == 0) script = locate_script(executable)
  if (command_argument_count() == 0) then
    write(error_unit,*) 'usage: gm_download URL OUTPUT [OPTIONS] or --tag TAG --catalog FILE --output FILE'
    stop 2
  end if

  ! Resolve a wrapper-specific override before forwarding Python's common options.
  first = 1
  value = argument(1)
  ! Reject an empty first argument before taking a one-character substring.
  if (len(value) == 0) stop 2
  if (value(1:1) /= '-') then
    if (command_argument_count() < 2) stop 2
    first = 3
  end if
  i = first
  do while (i <= command_argument_count())
    if (argument(i) == '--script') then
      i = i + 1
      if (i > command_argument_count()) stop 2
      script = argument(i)
    end if
    i = i + 1
  end do
  inquire(file=script, exist=found)
  if (.not. found) then
    write(error_unit,*) 'Downloader not found; set GM_DOWNLOADER or --script: ', script
    stop 2
  end if

  ! Decode all user data inside Python, avoiding shell expansion on both platforms.
  bootstrap = "import runpy,sys;runpy.run_path(bytes.fromhex(sys.argv.pop(1)).decode('utf-8'),run_name='__main__')"
  command = shell_quote(python)//' -c '//shell_quote(bootstrap)//' '//hex_bytes(script)//' --encoded-args'
  if (first == 3) then
    command = command//' x'//hex_bytes('--url')//' x'//hex_bytes(argument(1)) &
      //' x'//hex_bytes('--output')//' x'//hex_bytes(argument(2))
  end if
  i = first
  do while (i <= command_argument_count())
    value = argument(i)
    if (value == '--script') then
      i = i + 2
    else
      command = command//' x'//hex_bytes(value)
      i = i + 1
    end if
  end do

  ! Report launch errors separately from transfer or integrity failures.
  exit_status = 0
  call execute_command_line(command, exitstat=exit_status, cmdstat=command_status, cmdmsg=message)
  if (command_status /= 0) then
    write(error_unit,*) 'Unable to start Python: ', trim(message)
    stop 1
  end if
  if (exit_status /= 0) then
    write(error_unit,*) 'Python downloader failed with exit code ', exit_status
    stop 1
  end if

contains

  function argument(index) result(value)
    ! Allocate the exact argument length, including an intentionally empty argument.
    integer, intent(in) :: index
    character(:), allocatable :: value
    integer :: count
    call get_command_argument(index, length=count)
    allocate(character(count) :: value)
    call get_command_argument(index, value)
  end function argument

  function environment(name) result(value)
    ! Missing environment variables are represented by an empty initialized string.
    character(*), intent(in) :: name
    character(:), allocatable :: value
    integer :: count, status
    call get_environment_variable(name, length=count, status=status)
    if (status /= 0) count = 0
    allocate(character(count) :: value)
    value = repeat(' ', count)
    if (count > 0) call get_environment_variable(name, value)
  end function environment

  function hex_bytes(value) result(encoded)
    ! Command-line bytes are encoded without interpreting UTF-8 sequences or punctuation.
    character(*), intent(in) :: value
    character(:), allocatable :: encoded
    character(*), parameter :: digits = '0123456789abcdef'
    integer :: j, byte
    allocate(character(2*len(value)) :: encoded)
    do j = 1, len(value)
      byte = iachar(value(j:j))
      encoded(2*j-1:2*j-1) = digits(byte/16+1:byte/16+1)
      encoded(2*j:2*j) = digits(mod(byte,16)+1:mod(byte,16)+1)
    end do
  end function hex_bytes

  function shell_quote(value) result(quoted)
    ! Only the interpreter and fixed bootstrap enter the command processor's syntax.
    character(*), intent(in) :: value
    character(:), allocatable :: quoted
    integer :: j
    if (windows) then
      do j = 1, len(value)
        if (index('"%!'//achar(10)//achar(13), value(j:j)) /= 0) then
          write(error_unit,*) 'Use an interpreter path without shell expansion characters'
          stop 2
        end if
      end do
      quoted = '"'//value//'"'
    else
      quoted = achar(39)
      do j = 1, len(value)
        if (value(j:j) == achar(39)) then
          quoted = quoted//achar(39)//achar(34)//achar(39)//achar(34)//achar(39)
        else
          quoted = quoted//value(j:j)
        end if
      end do
      quoted = quoted//achar(39)
    end if
  end function shell_quote

  function locate_script(program) result(path)
    ! Find clients installed beside the binary, including invocation through PATH.
    character(*), intent(in) :: program
    character(:), allocatable :: path, exe, search, candidate, separator
    integer :: split, start, finish, delimiter
    logical :: present
    exe = program
    separator = '/'
    if (windows) separator = achar(92)
    split = max(index(exe, '/', back=.true.), index(exe, achar(92), back=.true.))
    if (split == 0) then
      search = environment('PATH')
      start = 1
      do while (start <= len(search))
        if (windows) then
          delimiter = index(search(start:), ';')
        else
          delimiter = index(search(start:), ':')
        end if
        finish = len(search)
        if (delimiter > 0) finish = start + delimiter - 2
        candidate = search(start:finish)//separator//program
        inquire(file=candidate, exist=present)
        if (present) then
          exe = candidate
          exit
        end if
        if (delimiter == 0) exit
        start = finish + 2
      end do
      split = max(index(exe, '/', back=.true.), index(exe, achar(92), back=.true.))
    end if
    if (split > 0) then
      path = exe(:split)//'download.py'
      inquire(file=path, exist=present)
      if (present) return
      path = exe(:split)//'clients'//separator//'download.py'
      inquire(file=path, exist=present)
      if (present) return
    end if
    ! Preserve repository-root invocation when clients are not installed together.
    path = 'clients'//separator//'download.py'
  end function locate_script
end program gm_download
