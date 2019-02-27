cd ..
feature=''
while [ "$feature" != 'q' ]; do
    echo 'which feature do you want to execute[2,3,4,5,c,q]'
    read feature
    if [ "$feature" = '2' ]; then
	if [ -e Project01/logs/todo.log ]; then
		rm Project01/logs/todo.log
	fi
        find . -type f -print0 | while IFS= read -d $'\0' file
       	    do
         	grep -E '#TODO' "$file" >> Project01/logs/todo.log
		if grep -Eq '#TODO' "$file" ; then
		  echo "$file"\ >> Project01/logs/todo.log
		fi
       	    done


    elif [ "$feature" = '3' ]; then
	if [ -e Project01/logs/compile_fail.log ]; then
                rm Project01/logs/compile_fail.log
	fi
        find . -name "*.py" -print0 | while IFS= read -d $'\0' file
            do
         	 python "$file" 2>> Project01/logs/compile_fail.log
       	    done
        find . -name "*.hs" -print0 | while IFS= read -d $'\0' file
       	    do
         	 runhaskell "$file" 2>> Project01/logs/compile_fail.log
       	    done

    elif [ "$feature" = '4' ]; then
	if [ -e Project01/logs/merge.log ]; then
                rm Project01/logs/merge.log
	fi
        git log --oneline | grep -E -i 'merge' | cut -d' ' -f1  >> Project01/logs/merge.log

    elif [ "$feature" = '5' ]; then
	git ls-files . --exclude-standard --others | grep -E .tmp | xargs rm
 
    elif [ "$feature" = 'c' ]; then
      	count=$(find . -type f | grep -E '.py' | wc -l)
      	total=$(find . -type f | wc -l)
      	echo $count python files of $total files found
      	ts=$(du -sh | cut -f1)
      	size=$(find . -type f | grep -E '.py' | xargs du -hc | grep total | cut -f1)
	echo python files take up "$size" of "$ts" space

    fi
done

