"""English reframing examples, part 3: longer messages with context, the way
people actually type when they're upset."""

DATA = [
    ("I studied for weeks and still got a 9/20. What's even the point of trying if this is the result?", "all_or_nothing", [
        "A 9 after weeks of work is painful, but it doesn't mean the effort was pointless.",
        "My study method might need changing, not my effort.",
        "I can ask for an exam review to see where the points went."]),
    ("My roommates always leave a mess and I never say anything. I'm such a pushover, nobody respects me.", "labeling", [
        "Avoiding conflict doesn't make me a pushover; speaking up is a skill I can practise.",
        "My roommates may not realise it bothers me.",
        "I can bring it up calmly and suggest a simple cleaning schedule."]),
    ("I applied to 20 internships and got 20 rejections. Clearly no company will ever want me.", "fortune_telling", [
        "Twenty rejections hurts, but the internship market is very competitive.",
        "Each rejection says little about future applications.",
        "The career centre could review my CV to improve the next round."]),
    ("I had a panic moment in the exam hall and had to step out for a minute. Everyone must think I'm weird now.", "mind_reading", [
        "Most people in an exam hall are focused on their own paper.",
        "Taking a minute to calm down was a sensible thing to do.",
        "If this happens often, I could ask about exam arrangements."]),
    ("My dad keeps asking about my grades and I always feel like I'm letting him down, even when I pass.", "mind_reading", [
        "Him asking might be his way of showing interest, not disappointment.",
        "Passing is an achievement, even if it doesn't feel like enough.",
        "I could tell him how the questions make me feel."]),
    ("I joined a study group but I barely talk. They probably wonder why I'm even there.", "mind_reading", [
        "Listening is also a way of contributing.",
        "They probably haven't thought much about how much I talk.",
        "I can share one idea or question next session."]),
    ("I took a gap year and now I feel like I'm years behind everyone my age.", "should_statements", [
        "A gap year gave me experiences others don't have.",
        "There isn't one right pace for life.",
        "A year feels huge now but will matter much less over time."]),
    ("My girlfriend broke up with me right before exams. I can't do anything right, not even relationships.", "overgeneralizing", [
        "A breakup is painful, but it doesn't mean I can't do anything right.",
        "It makes sense that exams feel harder right now.",
        "I can lean on friends and keep my study days simple."]),
    ("I was supposed to go running this morning but I stayed in bed. I'll never stick to anything.", "fortune_telling", [
        "Missing one run doesn't predict whether I'll stick to it.",
        "Habits are built over weeks with some missed days along the way.",
        "I can go for a short run tomorrow or even later today."]),
    ("My professor said my research question was too broad. I'm clearly not smart enough for a master's.", "overgeneralizing", [
        "Being told to narrow a question is standard feedback for most students.",
        "Refining a research question is part of doing research.",
        "This feedback helps me make my thesis more manageable."]),
    ("I keep comparing myself to my older brother who's a doctor. I'll always be the disappointing one.", "fortune_telling", [
        "My brother's path isn't the only measure of success.",
        "I have my own strengths and timing.",
        "My family can be proud of different things in each of us."]),
    ("I forgot to submit an assignment and got a zero. I'm so irresponsible, I can't trust myself with anything.", "overgeneralizing", [
        "Forgetting one assignment is a mistake, not proof I can't be trusted.",
        "I can set reminders so it's less likely to happen again.",
        "It's worth asking the professor if there's any way to make it up."]),
    ("Everyone in my kot seems to get along and I feel left out. They must not like me.", "mind_reading", [
        "Feeling left out doesn't mean they don't like me.",
        "Groups sometimes form by chance, not by deliberate choice.",
        "I can invite one housemate for coffee and get to know them better."]),
    ("I volunteered to organise the event and now I'm terrified it'll be a complete failure.", "catastrophizing", [
        "Feeling nervous shows I care about doing a good job.",
        "Events rarely go perfectly, and that's usually fine.",
        "I can make a checklist and ask others for help."]),
    ("I only slept four hours because I was worrying, and now today is definitely ruined.", "fortune_telling", [
        "A short night makes today harder, but not necessarily ruined.",
        "I can keep today simple and focus on the essentials.",
        "Going to bed a bit earlier tonight will help me recover."]),
    ("I cried in front of my supervisor. She must think I'm unprofessional now.", "mind_reading", [
        "Supervisors know students go through hard times.",
        "Showing emotion is human, not unprofessional.",
        "I could send a short thank-you message for her patience."]),
    ("My classmates all have side projects and I just do the basic coursework. I'm way behind.", "discounting_positives", [
        "Keeping up with coursework is already a real achievement.",
        "Side projects aren't the only way to grow.",
        "If I'm curious, I can start something small when I have energy."]),
    ("I gave a wrong answer in class and the whole room went quiet. I want to disappear.", "catastrophizing", [
        "Silence after an answer often just means people are thinking.",
        "Wrong answers are a normal part of learning out loud.",
        "By next week, nobody will remember this moment."]),
    ("I can't afford to go on the trip with my friends and they'll think I'm boring if I say no.", "mind_reading", [
        "Real friends understand budget limits.",
        "Saying no to one trip doesn't make me boring.",
        "I can suggest a cheaper plan we can do together."]),
    ("My mental health has been bad and my grades dropped. I've ruined my future.", "catastrophizing", [
        "A difficult semester doesn't decide my entire future.",
        "Grades can recover once I get the support I need.",
        "Talking to a student psychologist or advisor could really help."]),
    ("My best friend has a new group of friends and I feel replaced.", "personalization", [
        "Making new friends doesn't mean I've been replaced.",
        "Friendships can expand without ending.",
        "I can tell my friend I miss hanging out and suggest a plan."]),
    ("I read the exam questions and immediately felt like I knew nothing, so I probably failed.", "emotional_reasoning", [
        "The first moment of panic isn't an accurate measure of what I know.",
        "Many students feel blank at first and then remember more.",
        "I'll know my result when it comes, not before."]),
    ("I want to switch majors but that would mean admitting I wasted two years.", "all_or_nothing", [
        "The last two years taught me what I do and don't want.",
        "Some credits and skills may carry over.",
        "Changing direction is a brave and sensible choice."]),
    ("Group projects always end with me doing all the work.", "overgeneralizing", [
        "Some group projects went that way, but not necessarily all.",
        "I can agree on tasks and deadlines at the start this time.",
        "If it happens again, I can raise it with the group or the lecturer."]),
    ("My lab partner switched to another group, so I must be impossible to work with.", "personalization", [
        "People switch groups for many reasons, like schedules or friends.",
        "One partner leaving doesn't mean I'm impossible to work with.",
        "I could ask them about it if I want to know, without assuming the worst."]),
    ("I'm 22 and I've never been in a relationship. Something must be wrong with me.", "emotional_reasoning", [
        "There's no age by which people are supposed to have a relationship.",
        "Lots of people my age are in the same situation.",
        "My value doesn't depend on my relationship status."]),
    ("I had one bad day at my job and I'm sure they'll fire me.", "catastrophizing", [
        "One bad day is very unlikely to get anyone fired.",
        "Employers expect occasional off days.",
        "I can learn from what happened and move on tomorrow."]),
    ("My exam got postponed and my whole planning is messed up. Everything always goes wrong for me.", "overgeneralizing", [
        "A postponed exam is annoying, but it isn't everything going wrong.",
        "The extra time could even help me prepare.",
        "I can adjust my plan instead of starting over."]),
    ("I keep checking my grades every hour. If I don't do well, I won't know what to do with myself.", "catastrophizing", [
        "Checking constantly won't change the result.",
        "Whatever the grade, I'll find a way forward.",
        "I can set one time a day to check and do something kind for myself meanwhile."]),
    ("I need to get a perfect score on the resit or I'm done.", "all_or_nothing", [
        "I need to pass the resit, not get a perfect score.",
        "Setting a realistic target can lower the pressure.",
        "I can focus on the topics I lost the most points on."]),
    ("A classmate said my presentation was 'interesting'. That's what people say when it's bad.", "mind_reading", [
        "'Interesting' can simply mean interesting.",
        "I'm reading criticism into a neutral word.",
        "If I want real feedback, I can ask for it directly."]),
    ("I feel like I'm the only international student who isn't adjusting well.", "overgeneralizing", [
        "Adjusting to a new country takes time for almost everyone.",
        "Others may be struggling just as much without showing it.",
        "The international office often runs meetups that could help."]),
    ("My housemate complained about the noise once and now I feel like I can't do anything without bothering them.", "overgeneralizing", [
        "One complaint about noise doesn't mean everything I do bothers them.",
        "I can agree on quiet hours so I know what's okay.",
        "I'm allowed to live comfortably in my own home."]),
    ("I'm not as passionate about my studies as others seem to be. Maybe I'm just a fake.", "labeling", [
        "Passion comes and goes, especially during busy or stressful times.",
        "Not feeling excited every day doesn't make me a fake.",
        "I can notice the parts of my studies I do find interesting."]),
    ("My coach didn't play me this weekend. He thinks I'm the worst on the team.", "mind_reading", [
        "Line-up decisions depend on many things, like tactics and rotation.",
        "One weekend on the bench doesn't mean I'm the worst.",
        "I can ask the coach what I could work on."]),
    ("I couldn't finish the marathon, I'm a complete failure.", "all_or_nothing", [
        "Training for and starting a marathon is a big achievement.",
        "Not finishing this time doesn't make me a failure.",
        "I can learn from today and decide what I want to try next."]),
    ("I've had a headache for days and I'm sure it's something serious.", "catastrophizing", [
        "Headaches are often caused by stress, sleep or screens.",
        "If I'm worried, a GP can check it and give me clarity.",
        "Worrying about the worst case won't help as much as getting it checked."]),
    ("Everyone else understood the assignment instructions except me.", "overgeneralizing", [
        "I don't know that everyone else understood them.",
        "Instructions are often unclear, and others may be confused too.",
        "I can ask the lecturer or a classmate to clarify."]),
    ("I'm always tired, so I must be lazy.", "emotional_reasoning", [
        "Feeling tired often has causes like sleep, stress or workload.",
        "Tiredness isn't the same as laziness.",
        "I can look at my sleep and breaks this week."]),
    ("My ex is already dating someone else, so I was easy to replace.", "personalization", [
        "My ex moving on says more about them than about my worth.",
        "People cope with breakups in very different ways.",
        "I can focus on what helps me heal."]),
]
