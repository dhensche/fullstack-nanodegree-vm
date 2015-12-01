#
# Database access functions for the web forum.
#

# import time
import bleach
import psycopg2


def GetAllPosts():
    '''Get all the posts from the database, sorted with the newest first.

    Returns:
      A list of dictionaries, where each dictionary has a 'content' key
      pointing to the post content, and 'time' key pointing to the time
      it was posted.
    '''
    DB = psycopg2.connect('dbname=forum')
    c = DB.cursor()
    c.execute('select content, time from posts order by time desc')
    posts = [{'content': str(bleach.clean(row[0])), 'time': str(row[1])} for row in c.fetchall()]
    DB.close()
    return posts


def AddPost(content):
    '''Add a new post to the database.

    Args:
      content: The text content of the new post.
    '''
    DB = psycopg2.connect('dbname=forum')
    c = DB.cursor()
    c.execute("insert into posts (content) values (%s)", (bleach.clean(content),))
    DB.commit()
    DB.close()
