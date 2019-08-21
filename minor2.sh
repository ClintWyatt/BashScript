#!/bin/bash 

#Name: Clint Wyatt
#Id: 10656517
#course section: 001
#description: This bash script outputs the number of users currently logged into a cse machine. 
#The program will output the number of users every 10 seconds, and will let the user know who has logged in (if anyone logged in)
#and who has logged out (if anyone has logged out)

#The num varaible will be appended to a user that has appeared more than once
num=1
index=1
numUsers=0
hyph=- # used for multiple users logged in with the same name. Will be appended to a user that has appeared more than once


#using a array called added that holds the information of the current amount of users. Takes in the 
#number of users right after the sleep command is finished.
added=()

#using a array called left to let the user know which users have logged off. The data
#in left will be from the previous loop. Left is set equal to the added array at the end of
#the usersLoggedOff function, which is right before the sleep command.
left=()

#the below array will be used during the sameName function. The array will prevent us testing indexes that have had
#the users name appended by a '-'
cantTest=()

#traping a function called cantExit, with the signal 2 SIGINT
trap 'cantExit' 2

#Function will be executed if ctrl-c is pressed. 
cantExit()
{
echo  \(SIGINT\) ignored. enter ^C 1 more time to terminate program.
trap 2 #resets the signal
}

#the below function will print the users that have joined once the program starts
initialUsers()
{
	for (( j=0 ; $j<$numUsers ; j++ ))
	do
	if [ "${added[j]:6:1}" = $hyph ]; then
	echo "${added[j]:0:6}" is logged on to `uname -n`
	elif [ "${added[j]:7:1}" = $hyph ]; then
	echo "${added[j]:0:7}" is logged on to `uname -n`
	else
	echo ${added[j]} is logged on to `uname -n`

	fi
	done
	echo `date` \) \# of users: $numUsers
	left=("${added[@]}")

	let index++
}

#The below function will see if there are multiple users with the same user name

sameName()
{
	let local true=1;
	let test=0;
	let addedSize=${#added[@]}-2
	#testing cantTest()
	
	
	for (( k=0 ; $k<addedSize ; k++ ))
	do
	#initializing the size of the cantTest array
	let cantTestSize=${#cantTest[@]}

	#here, we will compare each index of the added index against itself. If the next index is the same as the
	#current index, then the end of the next index will have a number added to it.	
	
	
		for (( j=0 ; $j<addedSize ; j++ ))
		do	
			#in the following loop, if there are duplicate users, we want to make sure that 
			#we dont test the indexes again later in the loop
			for (( h=0; $h<cantTestSize ; h++ ))
			do
			#If there was a previos match between 2 users, we don't want to test k since its already appended with a -
			if [ $k = "${cantTest[h]}" ]; then
				let test=1;
			fi
			done
		#if test != true, then the current index can be tested against the parallel array.
		if [ $test != $true ];then

			#if j and k are not the same, then this if statement will execute. We don't want to test an index
			#against itself
			if [ $k != $j ]; then
				
				#if the user name occurs in another index
				if [ "${added[k]}" = "${added[j]}" ]; then
		 
				added[j]="${added[j]}$hyph$num"
				let num++ 
				cantTest+=($j) #adding the index the other user name was found to the cantTest array
				#break #we are breaking out of this loop, because if we don't, the program will be unable to detect 3 users logged in under one name
				fi
			fi
		fi
		let test=0
		done
	let num=1 #doing this since for the next username in the array, it wouldnt make sence to have cw0296-4 if there are only 2 cw0296 users
	let test=0;
	done
		
}

#The below function will print the user that have joined  (if any)
usersAdded()
{
	#making a local variable called notFound. Will be used to determine if a new user has logged in.
	let local notFound=0 
	local leftSize
	local addedSize
	let leftSize=${#left[@]}-2
	let addedSize=${#added[@]}-2
	
	#Here, we are using a nested for loop to compare the added array to the left array.
	for (( z=0 ; $z<addedSize ; z++ ))
	do
		
		#Here, we are comparing a single index of the added array to multiple(sometimes all) indexes of the left array. 
		#If the user in the added array is in the left array, then we break the loop. 
		for (( l=0 ; $l<leftSize ; l++ ))
		do

		#set -x
		if [ "${added[z]}" = "${left[l]}" ]; then

		break
		#elif [ "${added[z]:0:10}" = "${left[l]:0:10}" ]; then		
		#break

		#elif [ "${added[z]:0:9}" = "${left[l]:0:9}" ]; then		
		#break
		#elif [ "${added[z]:0:8}" = "${left[l]:0:8}" ]; then		
		#break
		#elif [ "${added[z]:0:7}" = "${left[l]:0:7}" ]; then
		#break
		else
		let notFound++
		fi

		done
	
	#If the not found varaible is the same as the size of the left array's size, then there
	#is a element in the added array that is not in left array, which means a new user has logged on.
	#In other words, added's "k" index is a new user that has logged on.
	if [ $notFound = $leftSize ]; then
		if [ "${added[z]:7:1}" = $hyph ]; then
		echo "${added[z]:0:7}" has logged on to `uname -n`
		elif [ "${added[z]:6:1}" = $hyph ]; then
		echo "${added[z]:0:6}" has logged on to `uname -n`
		else
		echo ${added[z]} has logged on to `uname -n`
		fi
		
	fi
	#resetting the not found variable for the next element in the added array
	notFound=0
	done	
	
}

#Function will tell user the other users that have logged off (if any) 
usersLoggedOff()
{
	#set -x
	#making a local variable called notFound. Will be used to determine if any users have logged off.
	let local notFound=0
	local leftSize
	local addedSize
	let leftSize=${#left[@]}-2
	let addedSize=${#added[@]}-2

	#We are using nested for loops to check the left array against the added array.  
	for (( a=0 ; $a<leftSize ; a++ ))
	do
		
		#In this for loop, we are comparing a single index in the left array to multiple indexes (sometimes all) of
		#the added array. If a index (user) in the left array is the same as the added array, then we break the loop: means
		#the user is still logged on.  
		for (( b=0 ; $b<addedSize ; b++ ))
		do
		if [ "${left[a]}" = "${added[b]}" ]; then
		break
		#elif [ "${left[a]:0:10}" = "${added[b]:0:10}" ]; then
		#break
		#elif [ "${left[a]:0:9}" = "${added[b]:0:9}" ]; then
		#break
		#elif [ "${left[a]:0:8}" = "${added[b]:0:8}" ]; then
		#break
		#elif [ "${left[a]:0:7}" = "${added[b]:0:7}" ]; then
		#break
		else
		let notFound++
		fi

		done

	#If notFound equals the added array's size, then a user at left's "a" index has logged off. 
	if [ $notFound = $addedSize ]; then
		if [ "${left[a]:7:1}" = $hyph ]; then
		echo "${left[a]:0:7}" has logged off `uname -n`
		elif [ "${left[a]:6:1}" = $hyph ]; then
		echo "${left[a]:0:6}" has logged off `uname -n`
		else
		echo ${left[a]}  has logged off `uname -n`
		fi


	fi
	
 	notFound=0
	done
	#setting the left array equal to the added array, which is the same a cloning the added array to the left array.
	left=("${added[@]}")
	#set +x
	
}

while true
do
	added=( $(who -q) )
	let numUsers=${#added[@]}-2

	if [ $index -eq 1 ]; then
	sameName
	initialUsers
	
	else
	sameName
	
	usersAdded
	usersLoggedOff
	echo `date` \) \# of users: $numUsers
	let index++
	fi
	let num=1
	#resettig the cantTest array to a empty array, since the user data 10 seconds later could be different.
	cantTest=()
sleep 10
done