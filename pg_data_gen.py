#!/usr/bin/python
import psycopg2
from psycopg2.extensions import AsIs
import sys
import math
import random
from random import randrange
import datetime

#testdata.py dbname tablename method count
def main():
  print("Starting")
  width = 340
  height = 160
  
  #Define our connection string
  conn_string = "host='localhost' dbname='"+sys.argv[1]+"' user='postgres' password='postgres'"
  conn = psycopg2.connect(conn_string)

  table = sys.argv[2]
  method = sys.argv[3]
  count = int(sys.argv[4])
  #Fill one table with the full fractal
  if (method == "multigeom"):
    cursor = conn.cursor()
    try:
      #delete existing
      print("attempt to remove old table")
      cursor.execute("DROP TABLE %s", (AsIs(table),))
      conn.commit()
    except Exception, e:
      print("DROP TABLE failed: "+str(e))
      conn.rollback()
    try:
      #create db
      cursor.execute("CREATE TABLE %s ( fid serial NOT NULL, point geometry(Point,4326), line geometry(LineString,4326), poly geometry(Polygon,4326), iteration integer, description varchar, create_date timestamp, CONSTRAINT %s PRIMARY KEY (fid) )", (AsIs(table), AsIs(table+"_pkey")))
      conn.commit()
      cursor.close()

      random.seed(123456)
  
      for i in range(1, count+1):
        multigeom(conn, table, i, width, height)
        conn.commit()
        print("added feature: ", i)
    finally:
      conn.rollback()
     
  conn.close()

def random_date():
  start_date = datetime.datetime(2010, 01, 01,01,00)
  rand_day = datetime.timedelta(days=randrange(28))
  date = start_date + rand_day + datetime.timedelta(minutes=random.random()*60)
  return date

def multigeom(conn, table, iteration, width, height):
  cursor = conn.cursor()

  px = random.random()*width - width/2
  py = random.random()*height - height/2

  lx1 = random.random()*width - width/2
  ly1 = random.random()*height - height/2
  lx2 = lx1+random.random()*10 - 5
  ly2 = ly1+random.random()*10 - 5

  pxnw = random.random()*width - width/2
  pynw = random.random()*height - height/2
  pxne = pxnw+random.random()*10 - 5
  pyne = pynw+random.random()*10 - 5
  pxse = pxne+random.random()*10 - 5
  pyse = pyne+random.random()*10 - 5
  pxsw = pxse+random.random()*10 - 5
  pysw = pyse+random.random()*10 - 5

  

  point = "ST_GeomFromText('POINT("+str(px)+" "+str(py)+")', 4326)"
  line = "ST_GeomFromText('LINESTRING("+str(lx1)+" "+str(ly1)+","+str(lx2)+" "+str(ly2)+")', 4326)"
  poly = "ST_GeomFromText('POLYGON(("+str(pxnw)+" "+str(pynw)+","+str(pxne)+" "+str(pyne)+","+str(pxse)+" "+str(pyse)+","+str(pxsw)+" "+str(pysw)+","+str(pxnw)+" "+str(pynw)+"))', 4326)"

  description = "multigeom[point("+str(px)+", "+str(py)+"), line("+str(lx1)+", "+str(lx2)+"), "+str(pxnw)+", "+str(pynw)+")]"
  date = random_date()

  cursor.execute("INSERT INTO %s (point, line, poly, iteration, description, create_date) VALUES (%s, %s, %s, %s,%s,%s)", (AsIs(table), AsIs(point), AsIs(line), AsIs(poly), iteration, description, date))
  cursor.close()

if __name__ == "__main__":
  main()