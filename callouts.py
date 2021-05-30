import os
import sqlite3


def main():
    head, tail = os.path.split(os.path.dirname(os.path.abspath(__file__)))

    bible_path = os.path.join(head, 'volumes', '32', 'deploy', '32.sqlite')
    bible_conn = sqlite3.connect(bible_path)
    bcv = bible_conn.cursor()
    bcv.execute('select bookNum, chapter, max(verse) as verse from verses group by bookNum, chapter')
    bcvs = []
    for bcv_row in bcv:
        bcvs.append((bcv_row[0], bcv_row[1], bcv_row[2]))

    callouts_path = os.path.join('assets', 'callouts.sqlite')
    if os.path.exists(callouts_path):
        os.remove(callouts_path)
    callouts_conn = sqlite3.connect(callouts_path)

    callouts_conn.execute(
        'create table callouts(volumeId INTEGER, book INTEGER, chapter INTEGER, ' \
        'verse INTEGER, itemId INTEGER)'
    )
    callouts_conn.execute(
        'create table learn(volumeId INTEGER, itemId INTEGER, learn TEXT)'
    )

    volumes = [1017, 1900]

    for volume_id in volumes:
        db_name = str(volume_id) + ".sqlite"
        db_path = os.path.join(head, 'volumes', str(volume_id), 'deploy', db_name)
        conn = sqlite3.connect(db_path)
        for bcv in bcvs:
            print('callouts for ' + str(volume_id) + ' book ' + str(bcv[0]) + ' chapter ' + str(bcv[1]))
            learn_items = []
            for verse in range(1, bcv[2] + 1):
                command = 'select itemId, learn from ResourceItems ri' + \
                ' inner join ResourceItemTypes rt on ri.id = rt.itemId' + \
                ' where book = ? and chapter = ?' + \
                ' and verse <= ? and endVerse >= ?' + \
                ' and type = 2 ' + \
                ' order by (endVerse - verse) limit 1'
                callouts = conn.cursor()
                callouts.execute(command, (str(bcv[0]), str(bcv[1]), str(verse), str(verse)))
                for callout in callouts:
                    callouts_conn.execute('insert into callouts values (?,?,?,?,?)',
                                          (str(volume_id), str(bcv[0]), str(bcv[1]), str(verse), str(callout[0])))

                    key = str(volume_id) + '_' + str(callout[0])
                    if key not in learn_items:
                        learn_items.append(key)
                        callouts_conn.execute('insert into learn values (?,?,?)', (str(volume_id), str(callout[0]),
                                                                                  str(callout[1])))

        callouts_conn.commit()

    callouts_conn.execute(
        'CREATE INDEX idx_callouts on callouts (volumeId, book, chapter, verse)'
    )
    callouts_conn.execute(
        'CREATE INDEX idx_learn on learn (volumeId, itemId)'
    )

    for book, chapter, max_verse in bcvs:
        print('remove duplicates for book ' + str(book) + ' chapter ' + str(chapter))
        for verse in range(0, 10):
            callouts = callouts_conn.cursor()
            callouts.execute(
                'select rowid, volumeId, verse, itemId from callouts where book = ' + str(book) + ' and ' + \
                'chapter = ' + str(chapter) + ' and verse % 10 = ' + str(verse) + ' order by verse')
            items = []
            verses = []
            for callout in callouts:
                key = str(callout[1]) + '_' + str(callout[3])
                if key in items or callout[2] in verses:
                    callouts_conn.execute('delete from callouts where rowid = ' + str(callout[0]))
                    continue
                items.append(key)
                verses.append(callout[2])
        callouts_conn.commit()

    for volume_id in volumes:
        extra_rows = callouts_conn.cursor()
        extra_rows.execute('delete from learn where volumeId = ' + str(volume_id) + ' and itemId not in ' + \
                      '(select itemId from callouts where volumeId = ' + str(volume_id) + ')')
        callouts_conn.commit()

    callouts_conn.execute(
        'vacuum'
    )


if __name__ == '__main__':
    main()