@echo off

set "folder_path=%userprofile%\Temp_batch_queue"
echo Files for the queue are put in %userprofile%\Temp_batch_queue
if not exist "%userprofile%\Temp_batch_queue" mkdir "%userprofile%\Temp_batch_queue"

REM Increment the number of jobs in the queue and add this job to the list of jobs waiting
set /p number=<%folder_path%\Number_of_jobs_in_the_queue.txt
set /a number+=1
echo %number% > %folder_path%\Number_of_jobs_in_the_queue.txt
set /p lastest_job_done_number=<%folder_path%\lastest_job_done.txt
echo This file is being executed as job %number% in the list of all jobs of which we have reached %lastest_job_done_number% completed jobs.
echo %number% %~dp0%~n0 %date% %time% >> %folder_path%\Jobs_waiting_to_run.txt

REM Wait for your turn in the queue
:loop1
set /p lastest_job_done_number=<%folder_path%\lastest_job_done.txt
set /a lastest_job_done_number_plus_one=lastest_job_done_number+1
if %lastest_job_done_number_plus_one% == %number% (
	echo It's my turn in the queue.
) else (
	set /a in_front = number-lastest_job_done_number-1
	echo Not yet my turn in the queue. Number of jobs in front %in_front%.
	timeout /t 2 >nul
	goto loop1
)

REM Make sure that the job in front is finished before starting this job
:loop2
if exist %folder_path%\Lock.txt (
    echo Waiting for lock...
    timeout /t 1 >nul
    goto loop2
)

REM Checks are done and the code can now be executed
echo Locking...
echo. > %folder_path%\Lock.txt REM set lock

REM **************************************************************
REM This is where you add your code
REM Here simulating something that takes time to execute
timeout /t 10 
REM **************************************************************

REM Remove the job from the list of jobs waiting
findstr /v /c:"%number% %~dp0%~n0" %folder_path%\Jobs_waiting_to_run.txt > %folder_path%\temp.txt
move /y %folder_path%\temp.txt %folder_path%\Jobs_waiting_to_run.txt

REM Add the job to the list of jobs completed
echo %number% %~dp0%~n0 %date% %time%>> %folder_path%\Jobs_completed.txt
REM Number of the latest job completed
echo %number% > %folder_path%\Lastest_job_done.txt

echo Unlocking...
del %folder_path%\lock.txt REM remove lock

