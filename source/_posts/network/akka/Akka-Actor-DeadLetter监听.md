---
title: Akka-Actor-DeadLetter监听

categories:
- network

tag:
- akka

---


## 1.自定义监听actor
```java
import akka.actor.UntypedActor;
import org.apache.commons.lang3.concurrent.BasicThreadFactory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * @author wuhao
 * @createTime 2021-09-26 17:06:00
 */
public class DeadLetterActor extends UntypedActor {

    private static int CLEAN_TIME = 5;
    private static int MAX_DEAD_LETTER = 1000;

    private static List<Object> deadLetterList = Collections.synchronizedList(new ArrayList());

    private static ScheduledExecutorService scheduledExecutorService =  new ScheduledThreadPoolExecutor(1,
            new BasicThreadFactory.Builder().namingPattern("dead-letter-schedule-pool-%d").daemon(true).build());

    static {
        scheduledExecutorService.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                deadLetterList.clear();
            }
        }, CLEAN_TIME, CLEAN_TIME, TimeUnit.MINUTES);
    }

    @Override
    public void onReceive(Object message) throws Throwable {
        addDeadLetter(message);
    }

    public static void addDeadLetter(Object message) {
        if (deadLetterList.size() < MAX_DEAD_LETTER) {
            deadLetterList.add(message);
        }
    }

    public static List<Object> getDeadLetter() {
        return deadLetterList;
    }

}
```
## 2.监听actor


```java
ActorRef deadLetterRef = akka.actorOf(Props.create(DeadLetterActor.class), "remoting-profiler-deadletter");
akka.eventStream().subscribe(deadLetterRef, DeadLetter.class);
```
