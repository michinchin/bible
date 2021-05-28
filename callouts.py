import os
import sqlite3


def main():
    head, tail = os.path.split(os.path.dirname(os.path.abspath(__file__)))

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

    bible_path = os.path.join(head, 'volumes', '32', 'deploy', '32.sqlite')
    bible_conn = sqlite3.connect(bible_path)
    bcv = bible_conn.cursor()
    bcv.execute('select bookNum, chapter, max(verse) as verse from verses group by bookNum, chapter')
    bcvs = []
    for bcv_row in bcv:
        bcvs.append((bcv_row[0], bcv_row[1], bcv_row[2]))

    for volume_id in [1017, 1900]:
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


if __name__ == '__main__':
    main()