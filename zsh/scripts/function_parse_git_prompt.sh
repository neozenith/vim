parse_git_prompt() {
  # Get diff and status
  # if there are any unstaged diffs then colour RED
  # if there are staged but uncommited work then YELLOW
  # Silence errors from stderr (2>) by routing to /dev/null especially when in non-Git directories
  # Pipe sane output to sed for cleanup

  # No branch -> No more work.
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [[ -n $BRANCH ]]; then

    RED="%F{red}"
    GREEN="%F{green}"
    YELLOW="%F{yellow}"
    BLUE="%F{blue}"
    PURPLE="%F{magenta}"
    NORM="%F{reset}"

    BRANCH_STATUS=""
    CACHE_STATUS=""
    REMOTE_STATUS=""

    # GIT STATUS
    STATUS=`git status --short --untracked-files 2> /dev/null`

    # Blue for no modifications or staged work
    STATUS_COLOUR="$BLUE"
    # No status -> no more work
    if [[ -n $STATUS ]]; then 
      
      # Yellow when there is any staged work
      STATUS_COLOUR="$YELLOW"
      # https://git-scm.com/docs/git-status#_short_format
      # https://git-scm.com/docs/git-diff#git-diff---diff-filterACDMRTUXB82308203
      STAT_UNT=`echo "$STATUS" | grep -e "^??" | wc -l | tr -d '[:space:]'`
      STAT_MOD=`echo "$STATUS" | grep -e "^[MDA ]M" | wc -l | tr -d '[:space:]'`
      STAT_DEL=`echo "$STATUS" | grep -e "^ D" | wc -l | tr -d '[:space:]'`
      STAT_ADD=`echo "$STATUS" | grep -e "^[MDAR]." | wc -l | tr -d '[:space:]'`
      STAT_CON=`echo "$STATUS" | grep -e "^.U" | wc -l | tr -d '[:space:]'`

      # Red for any unstaged modifications
      [[ $STAT_MOD > 0 ]] || [[ $STAT_UNT > 0 ]] || [[ $STAT_DEL > 0 ]] || [[ $STAT_CON > 0 ]] && STATUS_COLOUR="$RED"

      # If cache status changes are detected then accumulate
      [[ $STAT_UNT > 0 ]] && CACHE_STATUS="${CACHE_STATUS}$PURPLE?$STAT_UNT$NORM"
      [[ $STAT_MOD > 0 ]] && CACHE_STATUS="${CACHE_STATUS}$YELLOW~$STAT_MOD$NORM"
      [[ $STAT_DEL > 0 ]] && CACHE_STATUS="${CACHE_STATUS}$RED-$STAT_DEL$NORM"

      # Staged for commit
      [[ $STAT_ADD > 0 ]] && CACHE_STATUS="${CACHE_STATUS}$GREEN+$STAT_ADD$NORM"
      # Unresolved Merge path --> Merge Conflict
      [[ $STAT_CON > 0 ]] && CACHE_STATUS="$RED!$STAT_CON$NORM${CACHE_STATUS}"

      # If there is a cache status accumulated then prefix with a space
      [[ -n $CACHE_STATUS ]] && CACHE_STATUS=" [${CACHE_STATUS}]"
    fi
    
    REBASE_STATUS=""
    if [[ "$BRANCH" != "master" ]]; then
        REBASE_DELTA=`git cherry $BRANCH master 2> /dev/null | wc -l | tr -d '[:space:]'`
				if [ $REBASE_DELTA -gt 0 ]; then
	        REBASE_STATUS="${PURPLE}M→${GREEN}${REBASE_DELTA}${NORM}"
				fi
        
    fi
    BRANCH_STATUS="${REBASE_STATUS}${STATUS_COLOUR}⎇ ${BRANCH}${NORM}"

    # Remote status if you have fetched latest from remotes
    # 
    # For each remote, compare the remote tracking branch to the current branch
    # Then compare the other way arround.
    # `git cherry` will give a list of commit hashes which we will just count the lines (`wc -l`).
    # Only append the remote status if either are non zero.
    #
    # NOTE: This is ONLY looking at the local cache. I used to use git-radar
    # until I had issues with it running `git fetch` every time the prompt loaded.
    # Exacerbated when one company's policy was a password was required for every
    # git operation.... A password everytime I need a prompt? No thanks.
    #
    # https://stackoverflow.com/a/7940630/622276
    for r in `git remote 2> /dev/null`; do
      UP=`git cherry $r/$BRANCH $BRANCH 2> /dev/null | wc -l | tr -d '[:space:]'`
      DOWN=`git cherry $BRANCH $r/$BRANCH 2> /dev/null | wc -l | tr -d '[:space:]'`
      REMOTE_DELTA=""
      if [ $UP -gt  0 ] || [ $DOWN -gt 0 ] ;then
        REMOTE_DELTA="|${BLUE}↑${UP}${PURPLE}/${GREEN}↓${DOWN}"
      fi

      REBASE_STATUS=""
      REBASE_DELTA=0
      if [[ "$BRANCH" != "master" ]]; then
          REBASE_DELTA=`git cherry $BRANCH $r/master 2> /dev/null | wc -l | tr -d '[:space:]'`
          if [ $REBASE_DELTA -gt 0 ]; then
            REBASE_STATUS="${PURPLE}|M↓${GREEN}${REBASE_DELTA}${NORM}"
          fi
      fi
          

      if [ $UP -gt  0 ] || [ $DOWN -gt 0 ] || [ $REBASE_DELTA -gt 0 ];then
        REMOTE_STATUS="$REMOTE_STATUS ${PURPLE}${r}$REBASE_STATUS$REMOTE_DELTA$PURPLE|$NORM"
      fi

    done

    echo -e "\n${BRANCH_STATUS}${CACHE_STATUS}${REMOTE_STATUS}"

  fi
  
  
}


