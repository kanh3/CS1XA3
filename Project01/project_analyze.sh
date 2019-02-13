feature=''
while [ "$feature" != 'q' ]; do
    echo 'which feature do you want to execute[2,3,4,q]'
    read feature
    if [ "$feature" = '2' ]; then
      find . -type f -print0 | while IFS= read -d $'\0' file
        do
          grep -E '#TODO' $file >> todo.log
        done
    elif [ "$feature" = '3' ]; then
      find . -name *.py -print0 | while IFS= read -d $'\0' file
        do
          python "$file" 2>> compile_fail.log
        done
      find . -name *.hs -print0 | while IFS= read -d $'\0' file
        do
          runhaskell "$file" 2>> compile_fail.log
        done
    elif [ "$feature" = '4' ]; then
      git log -oneline | cut -d'' -f1 | grep -E 'merge' >> merge.log
    fi
done

