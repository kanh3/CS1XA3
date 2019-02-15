cd ..
feature=''
while [ "$feature" != 'q' ]; do
    echo 'which feature do you want to execute[2,3,4,q]'
    read feature
    if [ "$feature" = '2' ]; then
      find . -type f -print0 | while IFS= read -d $'\0' file
        do
	  if [ "$file" != "*$0" ]; then
         	 grep -E '#TODO' "$file" >> Project01/logs/todo.log
	  fi
        done
    elif [ "$feature" = '3' ]; then
      find . -name "*.py" -print0 | while IFS= read -d $'\0' file
        do
          python "$file" 2>> Project01/logs/compile_fail.log
        done
      find . -name "*.hs" -print0 | while IFS= read -d $'\0' file
        do
          runhaskell "$file" 2>> Project01/logs/compile_fail.log
        done
    elif [ "$feature" = '4' ]; then
      git log --oneline | grep -E -i 'merge' | cut -d' ' -f1  >> Project01/logs/merge.log
    fi
done

