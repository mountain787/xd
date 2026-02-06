#########################################################################
# File Name: restart.sh
# Author: genglut
# Mail: genglut@163.com
# Created Time: Sun 27 Feb 2022 04:42:55 PM CST
#########################################################################
#!/bin/bash


while true
do
	read -r -p "纭畾瑕侀噸鍚父鎴忔湇鍔★紵 [Y/n] " input

	case $input in
		[yY][eE][sS]|[yY])
			echo "姝ｅ湪閲嶅惎娓告垙鏈嶅姟......"
			/usr/local/games/xiand/all_restart.pike &
			exit 1
			;;

		[nN][oO]|[nN])
			echo "缁堟鎿嶄綔"
			exit 1	       	
			;;

		*)
		echo "鏃犳晥杈撳叆..."
			;;
	esac
done




#pike8 /usr/local/games/xiand/all_restart.pike &
