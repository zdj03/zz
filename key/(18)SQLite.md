SQLite是轻量型数据库；占用资源很少，是无类型的数据库（可以保存所有类型的数据）。存储数据的数据结构为B树，查询、插入和删除操作的时间复杂度为O(logn)，遍历操作的时间复杂度为O(1)。

#### 使用

- 1、打开数据库

  ```
  sqlite3_open(dbPath, &db)
  ```

  

- 2、建表

  ```sqlite
  create table 表名(字段名1 字段类型1，字段名2 字段类型2，...)
  create table if not exist表名(字段名1 字段类型1，字段名2 字段类型2，...)
  ```

  demo

  ```
  const char *sql = "CREATE TABLE IF NOT EXISTS t_Student(id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, score real DEFAULT 0, sex text DEFAULT '不明');";
  int ret = sqlite3_exec(_db, sql, NULL, NULL, NULL);
  if(ret == SQLITE_OK){
  
  } else {}
  ```

- 3、插入

  ```sqlite
  insert into 表名(字段1， 字段2，...) values(值1，值2，...)
  ```

  demo

  ```c
  const char *sql = "INSERT INTO t_Student(name, score, text) VALUES ('小明'， 65， '男');";
  int ret = sqlite3_exec(_db, sql, NULL, NULL, NULL);
  if(ret == SQLITE_OK){}else{}
  ```

- 4、更新

  ```sqlite
  update 表名 set 字段1 = 值1， 字段2 = 值2,...
  ```

  demo

  ```
  update t_Student set age=100 where age=10;
  ```

- 5、删除

  ```sqlite
  delete from 表名;//删除表中所有记录
  delete from 表名 where 条件
  ```

  demo

  ```sqlite
  const char *sql = "DELETE FROM t_Student WHERE score<10;";
  int ret = sqlite3_exec(_db, sql, NULL, NULL, NULL);
  if(ret){}else{}
  ```

- 6、查询

  ```sqlite
  select 字段1 字段2 from 表名;
  
  select * from stu where sex="男";
  select name, age from stu where sex="男";
  ```

  demo

  ```
  const char *sql = "SELECT name, score FROM t_Student;";
  //结果集(用来收集结果)
  sqlite3_stmt *stmt;
  int ret = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
  if(ret == SQLITE_OK){
  	//遍历结果集拿到查询数据
  	//sqlite3_step获取结果集中的数据
  	while(sqlite3_step(stmt) == SQLITE_ROW){
  		const char *name = sqlite3_column_text(stmt, 0);
  		double score = sqlite3_column_double(stmt, 1);
  	}
  } else{}
  ```







####B树



#### FMDB

- 5个源文件
  - FMDatabase：代表一个单独的SQLite操作实例，数据库通过它进行增删改查操作
  - FMResultSet：代表查询后的结果集
  - FMDatabaseQueue：代表串行队列，对多线程操作提供了支持
  - FMDatabaseAdditions：用于扩展FMDatabase，用于查找表是否存在，版本号等
  - FMDatabasePool：代表是任务池，对多线程提供了支持，官方不推荐使用



[FMDB源码详解](https://www.cnblogs.com/guohai-stronger/p/9246653.html)



#### ReactiveCocoa

https://www.cnblogs.com/guohai-stronger/p/10419156.html

#### 性能优化

- 内存
  - 内存布局
  - retain
  - weak
- RunLoop
  - NSTimer
  - RunLoop
- 界面
  - 内存泄漏
  - tableView优化
    - 高度
    - 重用机制
    - 渲染
    - 视图数目
    - 多余绘制
    - 不要动态添加subview
    - 异步UI，不要阻塞主线程
      - AsyncDisplayKit
    - 滑动时按需加载对应的内容
    - 离屏渲染
      - 遮罩layer.mask
      - masksToBounds、clipsToBounds设为yes
      - 阴影
      - 边角cornerRadius
      - 使用cgcontext的drawRect:



https://www.cnblogs.com/guohai-stronger/p/10430106.html

#### weak原理

weak表其实是一个哈希表，key是所指对象的指针，value是weak指针的地址数组。（value是数组的原因是：因为一个对象可能被多个弱引用指针指向）

Runtime维护了一张weak表，用来存储某个对象的所有的weak指针。

objc_initWeak

objc_storeWeak()

clearDeallocting

https://www.cnblogs.com/guohai-stronger/p/10161870.html