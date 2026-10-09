"""English reframing examples, part 2: shorter, messier, more realistic phrasing,
plus realistic worries with no distortion (pattern "none")."""

DATA = [
    ("i'm so dumb", "labeling", [
        "I'm having a hard moment, but that doesn't make me dumb.",
        "Everyone feels this way sometimes, especially when learning something new.",
        "I can figure out what's tripping me up and tackle that part."]),
    ("nothing ever works out for me", "overgeneralizing", [
        "Some things haven't worked out lately, but not everything ever.",
        "I can think of a few things that did go right recently.",
        "A rough patch feels permanent, but it usually isn't."]),
    ("i hate myself for wasting today", "labeling", [
        "Having an unproductive day doesn't make me someone to hate.",
        "Rest days happen, even unplanned ones.",
        "I can do one small thing now and start fresh tomorrow."]),
    ("why am i like this", "labeling", [
        "I'm frustrated with myself right now, and that's understandable.",
        "This moment is not the whole picture of who I am.",
        "I can be curious about what I need instead of harsh with myself."]),
    ("everyone's going out and i'm stuck studying again", "overgeneralizing", [
        "It feels like everyone, but probably plenty of people are studying too.",
        "This busy period is temporary, not my whole student life.",
        "I can plan something fun for after this deadline."]),
    ("can't focus. never could. never will.", "fortune_telling", [
        "I'm struggling to focus today, but I have focused well before.",
        "Concentration changes with sleep, stress and environment.",
        "I can try a short 20-minute block and see how it goes."]),
    ("my grades are trash", "all_or_nothing", [
        "Some of my grades are lower than I want, but not all of them.",
        "Grades can improve with a different approach.",
        "I can pick one course to focus on improving first."]),
    ("I'm behind on literally everything.", "overgeneralizing", [
        "I'm behind on some things, but probably not literally everything.",
        "Making a list might show it's more manageable than it feels.",
        "I can start with the task that has the nearest deadline."]),
    ("No one would notice if I skipped every class, I'm that irrelevant.", "labeling", [
        "Feeling unnoticed doesn't mean I'm irrelevant.",
        "People often notice more than they say.",
        "I matter to people in my life, even when it doesn't feel like it."]),
    ("I can't believe I said that, they'll never talk to me again.", "fortune_telling", [
        "I'm replaying it far more than they probably are.",
        "People usually forgive small awkward comments quickly.",
        "If it really bothers me, I can mention it lightly next time."]),
    ("tbh I think I'm just not meant for engineering", "emotional_reasoning", [
        "Struggling with hard material doesn't mean I'm not meant for it.",
        "Most engineering students have moments of doubt.",
        "I can talk to a study advisor before drawing big conclusions."]),
    ("I've wasted my whole first year.", "all_or_nothing", [
        "Even a hard year teaches me things I'll use later.",
        "I probably learned more than I'm giving myself credit for.",
        "I can make a plan for what I want next year to look like."]),
    ("I'm worried I won't be able to pay rent next month.", "none", [
        "This is a real concern, and it's good that I'm noticing it early.",
        "I can check what support the university's social services offer.",
        "Making a simple budget for this month will show me where I stand."]),
    ("My grandmother is sick and I can't concentrate on studying.", "none", [
        "It makes sense that I can't concentrate when someone I love is ill.",
        "I can let my study advisor know; there may be arrangements possible.",
        "Doing a little each day is enough right now."]),
    ("I have three exams in four days and I'm exhausted.", "none", [
        "That's a genuinely heavy schedule, and feeling exhausted is understandable.",
        "Sleep will help my memory more than one extra late night.",
        "I can plan short review sessions and real breaks between them."]),
    ("I don't know anyone in my new program.", "none", [
        "Starting somewhere new without knowing anyone is hard for most people.",
        "Others in my program are probably looking for people to know too.",
        "I can say hi to the person next to me in the next class."]),
    ("My laptop broke right before my deadline.", "none", [
        "That's really bad timing, and it's okay to be frustrated.",
        "The university library or IT service may have loan laptops.",
        "I can email my professor now to explain what happened."]),
    ("I'm homesick and it's getting worse.", "none", [
        "Homesickness is very common, especially in the first months.",
        "Scheduling a call with home can help without replacing life here.",
        "Building small routines here can make it feel more like home."]),
    ("I was sick for two weeks and missed a lot.", "none", [
        "Being ill isn't my fault, and catching up will take some time.",
        "I can ask the professors what's most important to catch up on.",
        "A medical certificate may give me options I don't know about yet."]),
    ("I'm nervous about my first day at my student job.", "none", [
        "Feeling nervous before something new is completely normal.",
        "Nobody expects me to know everything on day one.",
        "I can write down a few questions to ask my manager."]),
    ("I think my friends are drifting away since I moved.", "none", [
        "Distance can change friendships, and that can feel sad.",
        "Friendships that matter can adapt with some effort from both sides.",
        "I can set up a video call with the friend I miss most."]),
    ("The exam is tomorrow and I only studied half of it.", "none", [
        "Half the material is still a real foundation to work from.",
        "Tonight I can review key concepts instead of trying to learn everything.",
        "A good night's sleep will help me use what I already know."]),
    ("If I take a break, I'll never get back to work.", "fortune_telling", [
        "Taking a short break doesn't mean I can't return.",
        "Setting a timer for the break can make it easier to come back.",
        "Breaks often help me work better afterwards."]),
    ("Everyone on Instagram is living their best life and I'm not.", "overgeneralizing", [
        "Instagram shows highlights, not everyday life.",
        "Most people have boring and hard days they don't post.",
        "I can notice the small good things in my own week."]),
    ("I'm such a mess.", "labeling", [
        "Things feel messy right now, but I'm not a mess as a person.",
        "Hard periods make everyone feel scattered.",
        "I can sort out one small thing to feel a bit more in control."]),
    ("If my thesis isn't groundbreaking, it's pointless.", "all_or_nothing", [
        "Most good theses aren't groundbreaking, and they still matter.",
        "A solid, well-done thesis is a real achievement.",
        "My goal is to learn and show I can do research, not to change the world."]),
    ("The TA corrected me in front of everyone, I'm so embarrassed I want to switch groups.", "catastrophizing", [
        "Being corrected is part of learning, and it happens to everyone.",
        "Others likely forgot it by the end of the session.",
        "I don't need to change groups because of one moment."]),
    ("My best friend got into the master's and I didn't, I'm a loser.", "labeling", [
        "Not getting into one program doesn't make me a loser.",
        "I can be happy for my friend and disappointed for myself at the same time.",
        "There are other paths and programs that could suit me well."]),
    ("I'm getting fat because I don't have time to exercise, I disgust myself.", "labeling", [
        "My body changing during a busy time doesn't make me disgusting.",
        "I deserve kindness from myself, especially when things are hectic.",
        "Even a short walk between classes is a good place to start."]),
    ("I'm going to be the oldest one in my class and everyone will judge me.", "fortune_telling", [
        "People start or return to studies at all ages.",
        "My life experience can be a real advantage in class.",
        "Most classmates care more about their own studies than my age."]),
    ("I can't speak Dutch well, so I'll never fit in here.", "fortune_telling", [
        "Language takes time, and I'm already learning.",
        "Many people here are happy to switch languages or help me practise.",
        "Fitting in comes from shared interests too, not only language."]),
    ("My accent is so embarrassing, people must laugh at me behind my back.", "mind_reading", [
        "An accent shows I speak more than one language, which is impressive.",
        "Most people focus on what I say, not how it sounds.",
        "I don't actually have evidence that people laugh at me."]),
    ("I only got the job because they were desperate.", "discounting_positives", [
        "They chose me from the candidates they had, and that counts.",
        "Employers hire people they believe can do the job.",
        "I can show them they made a good choice."]),
    ("I need everyone to like me.", "should_statements", [
        "Nobody is liked by everyone, and that's okay.",
        "The people who matter most are the ones who like me as I am.",
        "Trying to please everyone usually leaves me exhausted."]),
    ("My partner didn't text back for hours, they must be losing interest.", "mind_reading", [
        "People get busy, and slow replies are rarely a message in themselves.",
        "I can't know what they're thinking without asking.",
        "If I'm worried, I can mention it calmly instead of guessing."]),
    ("I messed up one question, so the whole exam is ruined.", "all_or_nothing", [
        "One question is only a small part of the total score.",
        "I probably did well on many of the other questions.",
        "I'll know more when the grades come out, rather than guessing now."]),
    ("I'm too stressed to function.", "emotional_reasoning", [
        "I'm very stressed, but I'm still functioning more than I think.",
        "Stress is a signal to slow down, not proof I can't cope.",
        "A few minutes of slow breathing might take the edge off."]),
    ("If I don't answer emails instantly, people will think I'm unreliable.", "mind_reading", [
        "Most people don't expect instant replies.",
        "Responding within a day or two is normal and reliable.",
        "Setting times to check email can protect my focus."]),
    ("Every time I try something new I fail.", "overgeneralizing", [
        "Some new things haven't worked out, but not every single one.",
        "Failing at first is part of learning anything new.",
        "I can remember a time something new eventually went well."]),
    ("It's my fault my parents argue about money for my studies.", "personalization", [
        "My parents' arguments are between them, not my responsibility.",
        "Money stress has many causes beyond my studies.",
        "I can show I appreciate their support without carrying their conflict."]),
    ("They chose someone else as group leader, so they don't respect me.", "mind_reading", [
        "Choosing a leader is about one role, not about respecting me.",
        "There are many ways I can still contribute and be valued.",
        "I can ask what role would make best use of my strengths."]),
    ("I can't start until I fully understand everything.", "all_or_nothing", [
        "Understanding often grows while I'm working, not only before.",
        "I can start with the part I do understand.",
        "Waiting for complete understanding can keep me stuck."]),
    ("I've already lost so much time, there's no point trying now.", "all_or_nothing", [
        "Even with lost time, what I do now still matters.",
        "Small efforts over the next days can add up.",
        "I can focus on the most important parts instead of everything."]),
    ("I'll embarrass myself at the sports club because I'm unfit.", "fortune_telling", [
        "Most clubs welcome beginners; that's what they're for.",
        "Everyone at the club started somewhere.",
        "I can go once and see how it feels before deciding."]),
    ("My friend cancelled plans, she probably finds me boring.", "mind_reading", [
        "There are many reasons people cancel plans.",
        "Cancelling once doesn't mean she finds me boring.",
        "I can suggest another time and see how she responds."]),
    ("I feel like I don't deserve to be here.", "emotional_reasoning", [
        "Feeling like I don't belong is common and doesn't make it true.",
        "I earned my place here through my own work.",
        "I can list a few things that show I'm capable of this."]),
    ("My code didn't compile again, I'm a terrible programmer.", "labeling", [
        "Code not compiling is a normal part of programming for everyone.",
        "Errors are clues that help me fix things.",
        "I can read the error message carefully and fix one thing at a time."]),
    ("I have to finish this today or everything falls apart.", "catastrophizing", [
        "It would be good to finish today, but things won't fall apart if I don't.",
        "I can check what the real deadline and consequences are.",
        "Doing my best today is enough."]),
    ("I'm wasting my twenties studying something I don't even like.", "all_or_nothing", [
        "Studying something I'm unsure about still builds skills I can use.",
        "My twenties hold much more than this one program.",
        "I can explore what I'd enjoy more and talk to an advisor about options."]),
    ("I was the only one who didn't get the joke, everyone thinks I'm slow.", "mind_reading", [
        "Missing one joke happens to everyone.",
        "People rarely pay attention to who laughed and who didn't.",
        "I can just ask, and people usually enjoy explaining a joke."]),
    ("My exam results came out and I passed everything but I'm still not happy.", "discounting_positives", [
        "Passing everything is a real achievement worth acknowledging.",
        "It's okay to want more and still recognise what I achieved.",
        "I can take a moment to celebrate before setting new goals."]),
    ("I should be further along in life by now.", "should_statements", [
        "There's no fixed timeline everyone has to follow.",
        "Comparing myself to others' timelines doesn't reflect my own path.",
        "I can notice how far I've already come."]),
    ("If I tell my parents I'm struggling, they'll be so disappointed.", "fortune_telling", [
        "I can't be sure how they'll react until I talk to them.",
        "Parents often want to know when their child needs support.",
        "I can choose a calm moment and share as much as I feel ready to."]),
    ("I'm going to lose all my friends because I'm always too busy.", "catastrophizing", [
        "Being busy for a while doesn't mean losing all my friends.",
        "Good friends usually understand busy periods.",
        "I can send a quick message to let them know I'm thinking of them."]),
    ("I gained a few kilos, nobody will find me attractive.", "fortune_telling", [
        "Attraction isn't decided by a few kilos.",
        "People are drawn to personality, humour and kindness too.",
        "My body is allowed to change, and I deserve respect either way."]),
    ("I couldn't answer the interviewer's last question, so I didn't get the job.", "fortune_telling", [
        "One difficult question doesn't decide an entire interview.",
        "Interviewers look at the whole conversation.",
        "Whatever happens, I now know what to prepare for next time."]),
    ("Everybody notices when I blush.", "mind_reading", [
        "Blushing is often less visible than it feels.",
        "Even when people notice, most don't think about it again.",
        "Blushing is a normal reaction, not something to be ashamed of."]),
    ("The lecturer looked at me when he talked about plagiarism, he thinks I cheated.", "personalization", [
        "Lecturers look around the room; one glance doesn't mean anything specific.",
        "I know I did my own work.",
        "If I'm worried, I can ask him if there's anything I should know."]),
    ("I should be able to do it all: study, work, sport and a social life.", "should_statements", [
        "Doing everything at once is very hard for anyone.",
        "It's okay to prioritise some things during busy periods.",
        "I can decide what matters most this month."]),
    ("I wasn't picked for the team, I'm worthless at sports.", "labeling", [
        "Not being picked once doesn't make me worthless at sports.",
        "Team selection depends on many factors.",
        "I can keep playing for fun and improve at my own pace."]),
]
