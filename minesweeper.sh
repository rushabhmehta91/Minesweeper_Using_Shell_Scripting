#!/bin/bash
#Author: Mayur Sanghavi and Rushabh
#Minesweeper game implementation in bash shell
#usage:bash minesweeper.sh <userName>

#Check for username
if [ $# -gt 0 ]; then
	userName=$1
else 
	echo -n "Enter UserName: "
	read userName
fi

#Clear Screen
clear

#Initialize variables
declare -a board 	#board values
declare -a visited	#board state
declare -a minepos	#Location of mines
flags=0				#no. of flags set
correct=0			#Correct no. of mines locates
size=7				#size of board
mines=10			#no. of mines
moves=0				#Total moves by user
startT=-1			#Start time of game
endT=-1				#End time of game

##Function to print new board
##$1:Size $2:mines
function printBoard() {
	size=$1
	mines=$2
	flags=0;correct=0;moves=0
	echo "------------MineSweeper-------------"
	echo -n "Size: $size  "
	echo -n "Mines: $mines"
	echo " "
	for ((a=1;a<=$size;a++));
	do
		#10 spaces
		echo -n "          "
		for ((b=1;b<=$size;b++));
		do
			echo -n "# "
	   	done	
		echo 
   	done
	#column 7 and 18
	echo "Flags: 0   Moves: 0 "
	#Print controls
	echo "Move: a|w|s|d  Quit: q  Difficulty: b|n|m|x  Open-Mine: g|ENTER  Set/Unset-Flag: f"
	echo "Main Menu: z   "
	echo " "
	echo " "
}


##To open the mine
function onClick() {
	xpos=$(($1+1))
	ypos=$2
	if [ ${visited[$((ypos*size + xpos))]} -lt 2 ];	then
		if [ ${visited[$((ypos*size + xpos))]} -eq 1 ];then
			flags=$((flags-1))
			tput cup $(($size+min_y)) 7
			echo $flags" "
		fi
		visited[$((ypos*size + xpos))]=2
		if [ ${board[$((ypos*size + xpos))]} -eq -1 ];then
			#print Mine
			echo -e "\e[41;30m*\e[39;49m "
			#Reveal all unmarked mines
			for ((ind=0;ind<$mines;ind++))
			do
				#if not flagged
				if [ ${visited[${minepos[$ind]}]} -eq 0 ];then
					tput cup $(( (${minepos[$ind]}-1)/$size + min_y)) $((2*( (${minepos[$ind]}-1)%$size ) + min_x))
					echo -e "\e[41;30m*\e[39;49m "
				fi
			done
		tput cup $((min_y + $size + 3)) 0
		echo "Game Over! Press any key to continue.."
		read -s -n 1 temp
		x=0;y=0;
		clear		
		newGame $size $mines
		

		#If blank tile
		elif [ ${board[$((ypos*size + xpos))]} -eq 0 ]
		then
			tput cup $((ypos + min_y)) $(( 2 * $1 + min_x))
			echo "  " 
			xpos=$(($1-1));ypos=$2 #open left
			if [ $xpos -ge 0 ];then
				if [ ${board[$((ypos*size + xpos+1))]} -ge 0 ];then
					#tput cup $((ypos+min_y)) $((xpos+min_x))
					onClick $xpos $ypos
			fi;fi
			xpos=$(($1+1));ypos=$2 #open right
			if [ $xpos -lt $size ];then
				if [ ${board[$((ypos*size + xpos+1))]} -ge 0 ];then
					#tput cup $((ypos+min_y)) $((xpos+min_x))
					onClick $xpos $ypos
			fi;fi
			xpos=$1;ypos=$(($2-1)) #open top
			if [ $ypos -ge 0 ];then
				if [ ${board[$((ypos*size + xpos+1))]} -ge 0 ];then
					#tput cup $((ypos+min_y)) $((xpos+min_x))
					onClick $xpos $ypos
			fi;fi
			ypos=$(($2+1));xpos=$1 #open bottom
			if [ $ypos -lt $size ];then
				if [ ${board[$((ypos*size + xpos+1))]} -ge 0 ];then
					#tput cup $((ypos+min_y)) $((xpos+min_x))
					onClick $xpos $ypos
			fi;fi
			xpos=$(($1+1));ypos=$(($2-1)) #open NE
			if [ $xpos -lt $size -a $ypos -ge 0 ];then
				if [ ${board[$((ypos*size + xpos+1))]} -ge 0 ];then
					#tput cup $((ypos+min_y)) $((xpos+min_x))
					onClick $xpos $ypos
			fi;fi
			xpos=$(($1-1));ypos=$(($2-1)) #open NW
			if [ $xpos -ge 0 -a $ypos -ge 0 ];then
				if [ ${board[$((ypos*size + xpos+1))]} -ge 0 ];then
					#tput cup $((ypos+min_y)) $((xpos+min_x))
					onClick $xpos $ypos
			fi;fi
			xpos=$(($1+1));ypos=$(($2+1)) #open SE
			if [ $xpos -lt $size -a $ypos -lt $size ];then
				if [ ${board[$((ypos*size + xpos+1))]} -ge 0 ];then
					#tput cup $((ypos+min_y)) $((xpos+min_x))
					onClick $xpos $ypos
			fi;fi
			xpos=$(($1-1));ypos=$(($2+1)) #open SW
			if [ $xpos -ge 0 -a $ypos -lt $size ];then
				if [ ${board[$((ypos*size + xpos+1))]} -ge 0 ];then
					#tput cup $((ypos+min_y)) $((xpos+min_x))
					onClick $xpos $ypos
			fi;fi
		#Open tile
		else
			tput cup $((ypos + min_y)) $(( 2 * $1 + min_x))
			echo -e "\e[94m${board[$((ypos*size + xpos))]} \e[39m"
		fi
	fi
}

function flagClick() {
	xpos=$(($1+1))
	ypos=$2
	if [ ${visited[$((ypos*size + xpos))]} -eq 0 ]
	then
		flags=$((flags+1))
	    visited[$((ypos*size + xpos))]=1
		echo -e "\e[107;31mF\e[39;49m "
		tput cup $(($size+min_y)) 7
		echo $flags" "
		if [ ${board[$((ypos*size + xpos))]} -eq -1 ]
		then
			correct=$((correct+1))	
		fi
		if [ $correct -eq $mines -a $flags -eq $mines ]
		then
			tput cup $((min_y + $size + 3)) 0
			endT=`date +%s`
			
			checkForHighest $moves $size $userName $((endT - startT))
			echo "Congratulations you won! Press any key to continue.."			
			read -s -n 1 temp
			clear
			newGame $size $mines
		fi
	elif [ ${visited[$((ypos*size + xpos))]} -eq 1 ]
	then
		flags=$((flags-1))
		visited[$((ypos*size + xpos))]=0
		echo "# "
		tput cup $(($size+min_y)) 7
		echo $flags" "
		if [ ${board[$((ypos*size + xpos))]} -eq -1 ]
		then
			correct=$((correct-1))	
		fi
	fi
}

##Start new game
#$1:size $2:No. of mines
function newGame(){
	
	size=$1
	mines=$2
	index=0
	flags=0
	correct=0
	len=`expr $size \* $size`
	for ((a=1;a<=$len;a++));
	do
		board[$a]=0
		visited[$a]=0
	done
	##Set mines
	while [ $index -lt $mines ]
	do
		pos=$(($RANDOM % ( $size * $size ) + 1))
		if [[ ${board[$pos]} -ge 0 ]]
		then
			minepos[$index]=$pos
			board[$pos]=-1
#			echo $index": "${minepos[$index]}
			index=`expr $index + 1`
			#East
			if [ $(( $pos % $size )) -ne 0 ];then if [ ${board[$(($pos + 1))]} -ne -1 ]
			then
			board[$(($pos + 1))]=`expr ${board[$(($pos + 1))]} + 1`
			fi;fi
			#W
			if [ $(( $pos % $size )) -ne 1 ];then if [ ${board[$(($pos - 1))]} -ne -1 ]
			then
			board[$(($pos - 1))]=`expr ${board[$(($pos - 1))]} + 1`
			fi;fi
			#N
			if [ $pos -gt $size ];then if [ ${board[$(($pos - $size))]} -ne -1 ]
			then
			board[$(($pos - $size))]=`expr ${board[$(($pos - $size))]} + 1`
			fi;fi
			#S
			if [ $(($pos + $size)) -le $len ];then if [ ${board[$(($pos + $size))]} -ne -1 ]
			then
			board[$(($pos + $size))]=`expr ${board[$(($pos + $size))]} + 1`
			fi;fi
			#NE
			if [ $pos -gt $size -a $(( $pos % $size )) -ne 0 ];then if [ ${board[$(($pos - $size + 1))]} -ne -1 ]
			then
			board[$(($pos - $size + 1))]=`expr ${board[$(($pos - $size + 1))]} + 1`
			fi;fi
			#NW
			if [ $pos -gt $size -a $(( $pos % $size )) -ne 1 ];then if [ ${board[$(($pos - $size - 1))]} -ne -1 ]
			then
			board[$(($pos - $size - 1))]=`expr ${board[$(($pos - $size - 1))]} + 1`
			fi;fi
			#SE
			if [ $(($pos + $size)) -le $len -a $(( $pos % $size )) -ne 0 ];then if [ ${board[$(($pos + $size + 1))]} -ne -1 ]
			then
			board[$(($pos + $size + 1))]=`expr ${board[$(($pos + $size + 1))]} + 1`
			fi;fi
			#SW
			if [ $(($pos + $size)) -le $len -a $(( $pos % $size )) -ne 1 ];then if [ ${board[$(($pos + $size - 1))]} -ne -1 ]
			then
			board[$(($pos + $size - 1))]=`expr ${board[$(($pos + $size - 1))]} + 1`
			fi;fi
		fi
	done
	
	printBoard $size $mines
}

function startGame(){
	size=$1
	mines=$2
	getLowestScore
	newGame $size $mines
	min_x=10
	max_x=`expr 10 + $size \* 2 - 2`
	min_y=2
	max_y=`expr 4 + $size`
	x=0
	y=0
	startT=`date +%s`
	while true
	do

	tput cup $((y + min_y)) $((2*x + min_x))
	read -s -n 1 key
	case $key in
		'a')	x=`expr $x - 1`
			if [ $x -lt 1 ]; then 
				x=0
			fi;;

		'd')	x=`expr $x + 1`
			if [ ! $x -lt $size ]; then 
				x=`expr $size - 1`
			fi;;

		'w')	y=`expr $y - 1`
			if [ $y -lt 1 ]; then 
				y=0
			fi;;

		's')	y=`expr $y + 1`
			if [ ! $y -lt $size ]; then 
				y=`expr $size - 1`	
			fi;;

		'g'|'G'|'')    onClick  $x $y
					moves=$((moves+1))
					tput cup $(($size+min_y)) 18
					echo $moves" ";;
		'f'|'F')	flagClick $x $y;;
		'b')clear
			x=0;y=0;size=7;mines=10
			newGame $size $mines;;
		'n')clear
			x=0;y=0;size=10;mines=15
			newGame $size $mines;;
		
		'm')clear
			x=0;y=0;size=13;mines=20
			newGame $size $mines;;
		'x')clear
			x=0;y=0;size=20;mines=60
			newGame $size $mines;;
		
		'q'|'Q')	echo		
			clear
			echo "Thank you for playing Minesweeper"
			exit 0;;
		'z'|'Z') break;;
	esac
	done

	clear
}


function getLowestScore(){
if [ ! -f highScore ];then
	echo "Beginner:board" >> highScore
	echo "rdm:50:200:b:5" >> highScore
	echo "Novice:board" >> highScore
	echo "rdm:100:500:n:5" >> highScore
	echo "Master:board" >> highScore
	echo "mms:167:234:m:5" >> highScore
	echo "Expert:board" >> highScore
	echo "mms:193:567:e:5" >> highScore
fi
beginner_low_moves=`grep 'b:5' highScore | cut -d':' -f2`
beginner_low_time=`grep 'b:5' highScore | cut -d':' -f3`
novice_low_moves=`grep 'n:5' highScore | cut -d':' -f2`
novice_low_time=`grep 'n:5' highScore | cut -d':' -f3`
master_low_moves=`grep 'm:5' highScore | cut -d':' -f2`
master_low_time=`grep 'm:5' highScore | cut -d':' -f3`
expert_low_moves=`grep 'e:5' highScore | cut -d':' -f2`
expert_low_time=`grep 'e:5' highScore | cut -d':' -f3`
}


function checkForHighest(){
	case $2 in
	'7')	echo "$1 : $beginner_low_moves"
		if [ $1 -lt $beginner_low_moves ];then
			sed "s/.*:b:5/$3:$1:$4:b:5/g" highScore > highScore
		fi;;
	'10')	if [ $1 -lt $novice_low_moves ];then 
			sed "s/.*:n:5/$3:$1:$4:n:5/g" highScore > highScore
		fi;;
	'13')	if [ $1 -lt $master_low_moves ];then
			sed "s/.*:m:5/$3:$1:$4:m:5/g" highScore > highScore
		fi;;
	'20')	if [ $1 -lt $expert_low_moves ];then
			sed "s/.*:e:5/$3:$1:$4:e:5/g" highScore > highScore
		fi;;
	esac
}


#To close script
function quit(){
	echo
	clear
	echo "Thank you for playing Minesweeper"
	exit 0

}
# trap SIGINT SIGQUIT SIGTRAP
trapFunction(){
	trap 'echo "Interrupt by SIGINT";quit;exit 1' SIGINT
	trap 'echo "Interrupt by SIGQUIT";quit;exit 1' SIGQUIT
	trap 'echo "Interrupt by SIGTRAP";quit;exit 1' SIGTRAP
}

#To set user name
function changeUser(){
clear
echo -n "Enter Username: "
read username
echo "Username changed: $username"
sleep 3 
}

function highScore(){
clear
echo "----------------------Highscores-------------------------"
printf "%10s\t%10s\t%10s\n" "Username" "Moves" "Time"
if [ -f highScore ];then
while read readline;do
		high_user=`echo $readline|cut -d ":" -f1`
		high_moves=`echo $readline|cut -d ":" -f2`
		if [ "$high_moves" == "board" ];then
			printf "%s%s%s\n" "----------------Difficulty level:" "$high_user" "----------------"
		continue
		fi
		high_time=`echo $readline|cut -d ":" -f3`
		printf "%10s\t%10i\t%10i\n" $high_user $high_moves $high_time
done <highScore
else 
	echo "No High SCores available"
fi
echo "Press any key to go back to main menu"
read -s -n 1 kk 
}


function optionFinder(){
case $1 in
	'1')clear
	startGame $size $mines;;
	'2')changeUser;;
	'3')highScore;;
	'4')quit ;;
esac
}

#Presents Main Menu to player
function mainMenu(){
while true;do
	clear
	echo "Welcome to the Puzzle world of minesweeper"
	min_x=0
	min_y=0

	echo "> New Game"
	echo "> Change User"
	echo "> View High Score"
	echo "> Quit"
	option=1
	while true;do
		tput cup $(($min_y+$option)) $min_x
		read -s -n 1 key
		case $key in

			'w'|'A')  option=`expr $option - 1`
				if [ $option -lt 1 ];then
					option=1
				fi;;
			's'|'B')  option=`expr $option + 1`
				if [ $option -gt 4 ];then
					option=4
				fi;;
			'n') optionFinder 1
			break;;
			'c') optionFinder 2
			break;;
			'h') optionFinder 3
			break;;
			'q') optionFinder 4
			break;;

			'g'|'')	optionFinder $option 
					break;;
		esac 
	done
done
}

#Trap for interrupts
trapFunction
#Start the script
mainMenu
