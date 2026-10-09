"""English reframing examples, part 1. (thought, pattern, [three alternative thoughts])"""

DATA = [
    ("I bombed my first midterm, I'm clearly not cut out for university.", "overgeneralizing", [
        "One midterm is a single data point, not a verdict on whether I belong here.",
        "Lots of students struggle with their first exams while they learn how university tests work.",
        "I can look at what went wrong and change how I prepare for the next one."]),
    ("If I don't get at least a 16 on this, I'm a failure.", "all_or_nothing", [
        "A grade below 16 would still show I learned a lot of the material.",
        "My worth isn't decided by one number on one exam.",
        "Aiming high is good, but anything between pass and perfect still counts."]),
    ("My group members are going to hate me because my part isn't finished.", "fortune_telling", [
        "I don't know how they'll react; telling them early usually goes better than I expect.",
        "Group members tend to appreciate honesty about delays more than silence.",
        "I can tell them when my part will be done and ask if anyone needs something sooner."]),
    ("I said something stupid in the seminar and now everyone thinks I'm an idiot.", "mind_reading", [
        "Most people are too focused on their own contributions to remember one comment of mine.",
        "Asking or saying something imperfect is part of how seminars are supposed to work.",
        "Even if one comment came out wrong, it doesn't erase everything else I've contributed."]),
    ("I procrastinated all week, I'm just a lazy person.", "labeling", [
        "Putting things off this week doesn't make me lazy; it might mean I'm tired or overwhelmed.",
        "I've worked hard plenty of times before, so this isn't who I am.",
        "I can start with one small task today instead of judging the whole week."]),
    ("I should have started studying weeks ago.", "should_statements", [
        "Starting earlier would have helped, but I can only work with the time I have now.",
        "Beating myself up about the past won't give me back that time.",
        "Making a realistic plan for the days left is more useful than regret."]),
    ("Everyone else in my program is smarter than me.", "overgeneralizing", [
        "I'm comparing my insides to other people's outsides; they have doubts too.",
        "I got into this program for a reason, just like they did.",
        "People are good at different things, and I have strengths of my own here."]),
    ("I didn't get invited to the party, nobody here likes me.", "overgeneralizing", [
        "Not being invited to one party doesn't mean nobody likes me.",
        "There could be lots of reasons I wasn't invited that have nothing to do with me.",
        "I can reach out to someone I get along with and make my own plans."]),
    ("My exam went fine but that was only because the questions were easy.", "discounting_positives", [
        "The exam went well partly because I prepared for it.",
        "If the questions felt easy, that might mean I understood the material.",
        "I'm allowed to take credit when things go right, not only blame when they don't."]),
    ("I feel overwhelmed, so I must be doing everything wrong.", "emotional_reasoning", [
        "Feeling overwhelmed tells me I have a lot on my plate, not that I'm failing.",
        "My feelings are real, but they aren't proof of how well I'm doing.",
        "I can list what's actually done and see that I'm handling more than I think."]),
    ("My friend seemed cold today, it's probably something I did.", "personalization", [
        "My friend might be dealing with something that has nothing to do with me.",
        "One distant day doesn't mean our friendship has changed.",
        "If it keeps bothering me, I can simply ask if everything's okay."]),
    ("I'm going to blank during the oral exam, I just know it.", "fortune_telling", [
        "I can't know that in advance, and I've answered questions under pressure before.",
        "Even if I pause, examiners often help or rephrase the question.",
        "Practising out loud a few times can make blanking less likely."]),
    ("If I fail this course, I'll lose my scholarship and my life is ruined.", "catastrophizing", [
        "Failing one course would be hard, but there are usually resits and options.",
        "I can check the actual scholarship rules instead of assuming the worst.",
        "Even setbacks that feel huge now are usually recoverable with support."]),
    ("I'm terrible at making friends.", "labeling", [
        "Making friends takes time for most people, especially in a new place.",
        "I have made friends before, so I'm capable of it.",
        "I could join one club or activity where conversations happen naturally."]),
    ("I got one comment of criticism on my paper, so the whole thing is bad.", "discounting_positives", [
        "One critical comment doesn't cancel out the parts that worked.",
        "Feedback is meant to help me improve, not to grade me as a person.",
        "I can fix that point and keep the rest of the paper as it is."]),
    ("I should never feel stressed about exams, other people don't.", "should_statements", [
        "Most students feel stressed about exams, even if they don't show it.",
        "Some stress is a normal response to something that matters to me.",
        "I can look for ways to manage stress instead of trying to never feel it."]),
    ("I missed one lecture and now I'll never catch up.", "catastrophizing", [
        "Missing one lecture is very common and usually easy to make up.",
        "I can check the slides or recording, or ask a classmate for notes.",
        "Catching up on one session is a small, manageable task."]),
    ("My parents are disappointed in me because I changed programs.", "mind_reading", [
        "I don't actually know what they feel unless I ask them.",
        "Parents can be surprised at first and still support a decision later.",
        "Choosing a program that fits me better is a responsible choice."]),
    ("I'll never be as good at coding as the others in my class.", "fortune_telling", [
        "Coding is a skill that grows with practice, not something people are born with.",
        "The others started earlier or practised more; I can close the gap over time.",
        "I've already learned things that once seemed impossible to me."]),
    ("I ate badly all week, I have no self-control.", "labeling", [
        "A rough week of eating doesn't define my self-control.",
        "Busy periods make healthy routines harder for almost everyone.",
        "I can plan one easy, decent meal tomorrow and build from there."]),
    ("My presentation had one awkward moment, so it was a disaster.", "all_or_nothing", [
        "One awkward moment doesn't turn the whole presentation into a disaster.",
        "The audience probably remembers the content more than one pause.",
        "Most of my presentation went as planned, and that counts."]),
    ("Nobody answered my message in the group chat, they're ignoring me.", "mind_reading", [
        "People often read messages and forget to reply, especially when they're busy.",
        "Silence in a group chat rarely means everyone decided to ignore me.",
        "I can follow up with one person directly if it matters."]),
    ("If I ask for an extension, the professor will think I'm lazy.", "mind_reading", [
        "Professors get extension requests all the time and usually take them in stride.",
        "Asking early and explaining briefly shows responsibility, not laziness.",
        "Whatever the answer, asking is better than handing in rushed work."]),
    ("I'm always the one who messes things up in the lab.", "overgeneralizing", [
        "I'm remembering the mistakes and forgetting the experiments that went fine.",
        "Everyone makes errors in the lab; that's how people learn the techniques.",
        "I can ask the assistant to watch me once and give me tips."]),
    ("I feel lonely, so there must be something wrong with me.", "emotional_reasoning", [
        "Feeling lonely is a common human experience, especially at university.",
        "Loneliness tells me I want more connection, not that I'm broken.",
        "I can take one small step toward people this week, like a study session."]),
    ("My roommate is upset and it's my fault.", "personalization", [
        "My roommate's mood can have lots of causes outside our shared space.",
        "If something I did bothered them, we can talk about it calmly.",
        "I don't have to take responsibility for every feeling around me."]),
    ("I got a B, which basically means I didn't try.", "discounting_positives", [
        "A B shows real effort and understanding.",
        "One grade doesn't measure how hard I actually worked.",
        "I can be proud of this result and still aim higher next time."]),
    ("I have to be productive every single hour or I'm wasting my life.", "should_statements", [
        "Rest is part of being productive, not the opposite of it.",
        "Nobody works every hour, and trying to will burn me out.",
        "A few focused hours a day can achieve more than constant pressure."]),
    ("I'll never find a job after graduating.", "fortune_telling", [
        "I can't predict the future, and most graduates do find work eventually.",
        "Job searching takes time, but each application teaches me something.",
        "I can use the career centre and my network to improve my chances."]),
    ("I stumbled over my words when I talked to my crush, I ruined everything.", "catastrophizing", [
        "Stumbling over words is normal when I'm nervous and often comes across as sweet.",
        "One clumsy moment rarely decides how someone sees me.",
        "There will be other chances to talk more naturally."]),
    ("My thesis is never going to be good enough.", "fortune_telling", [
        "A thesis doesn't have to be perfect; it has to be finished and solid.",
        "My supervisor's feedback can tell me what good enough looks like.",
        "Working on one section at a time makes it more manageable."]),
    ("I can't do anything right.", "overgeneralizing", [
        "That's not true; I do plenty of things right every day.",
        "I'm focusing on what went wrong and forgetting what went well.",
        "I can name three things I handled okay this week."]),
    ("I'm a burden to my friends when I talk about my problems.", "mind_reading", [
        "Friends often feel closer when someone trusts them with something real.",
        "I'd want to support them, and they likely feel the same about me.",
        "I can share and also ask how they're doing, so it feels balanced."]),
    ("Since I didn't understand today's lecture, I'm going to fail the exam.", "fortune_telling", [
        "Not understanding one lecture is normal; things often click later.",
        "There's still time to review, ask questions, or go to office hours.",
        "One confusing session doesn't predict the whole exam."]),
    ("I should be over my breakup by now.", "should_statements", [
        "There's no deadline for getting over someone.",
        "Healing takes the time it takes, and it isn't a straight line.",
        "I can be patient with myself and keep doing things that help."]),
    ("I'm the only one in my year who's struggling.", "overgeneralizing", [
        "Many people struggle quietly, so it only looks like I'm the only one.",
        "If I asked around, I'd probably find others who feel the same.",
        "Struggling is part of learning hard things, not a sign I'm alone."]),
    ("I forgot my friend's birthday, I'm a terrible friend.", "labeling", [
        "Forgetting a birthday is a mistake, not proof that I'm a terrible friend.",
        "I can send a message now; a late wish still means something.",
        "I show I care about my friends in plenty of other ways."]),
    ("My supervisor gave me a lot of feedback, so my work must be awful.", "emotional_reasoning", [
        "Detailed feedback often means my supervisor takes my work seriously.",
        "Lots of comments are normal for a draft; that's what drafts are for.",
        "I can go through the feedback one point at a time."]),
    ("Everyone is going to see how anxious I am during my talk.", "mind_reading", [
        "I usually feel far more nervous than I look to others.",
        "Most of the audience is focused on the content, not on my nerves.",
        "Even if they notice, people tend to be understanding."]),
    ("I failed my driving test, I'm useless at everything.", "overgeneralizing", [
        "Failing one test doesn't mean I'm useless at everything.",
        "Lots of people pass on their second or third try.",
        "I now know exactly what to practise before the next attempt."]),
    ("It's my fault our team lost the case competition.", "personalization", [
        "A team result depends on everyone and on factors no one controls.",
        "I contributed to the team, and so did the others.",
        "We can look at what to improve together next time."]),
    ("If I can't get everything done today, the whole week is wasted.", "all_or_nothing", [
        "Getting some things done today is still progress.",
        "The week isn't ruined by one unfinished to-do list.",
        "I can choose the two most important tasks and let the rest wait."]),
    ("I'm too shy to ever have a social life here.", "fortune_telling", [
        "Being shy can make it slower, but plenty of shy people build good friendships.",
        "Small settings like study groups or clubs can feel easier for me.",
        "I don't need to become outgoing; I just need a few good connections."]),
    ("I spent too much money this month, I'm hopeless with finances.", "labeling", [
        "Overspending one month doesn't make me hopeless with money.",
        "Lots of students are still learning how to budget.",
        "I can look at where the money went and set one simple limit."]),
    ("My essay got a lower grade than my friend's, so I'm not smart.", "discounting_positives", [
        "A different grade on one essay doesn't measure my intelligence.",
        "My friend and I have different strengths and different subjects.",
        "I can look at the feedback and use it for the next essay."]),
    ("I can't relax until every task is finished.", "should_statements", [
        "There will always be another task; I'm allowed to rest anyway.",
        "Taking a break can help me work better afterwards.",
        "I can decide on a stopping point for today and stick to it."]),
    ("I didn't speak up in the meeting, so I'm invisible to everyone.", "overgeneralizing", [
        "Not speaking up once doesn't make me invisible.",
        "I can prepare one point to share in the next meeting.",
        "People notice my work in other ways too."]),
    ("I feel stupid asking questions, so my questions must be stupid.", "emotional_reasoning", [
        "Feeling awkward doesn't make the question stupid.",
        "Often other people have the same question but don't ask.",
        "Asking is how I learn faster than guessing."]),
    ("My mom sounded stressed on the phone, I must be the reason.", "personalization", [
        "My mom has many things going on that could stress her.",
        "If I'm worried, I can gently ask her how she's doing.",
        "I'm not responsible for every mood the people I love have."]),
    ("I'll be alone forever.", "fortune_telling", [
        "I can't know what the future holds, and feelings now aren't predictions.",
        "Connection often comes when I don't expect it.",
        "I can focus on building friendships one step at a time."]),
    ("I need to be the best in my class or I've failed.", "all_or_nothing", [
        "There's a lot of room between being the best and failing.",
        "Learning and growing matter more than my ranking.",
        "I can set a goal based on my own progress, not others'."]),
    ("I got rejected from the student association, nobody wants me around.", "overgeneralizing", [
        "One rejection is about one selection process, not about everyone.",
        "Selection depends on many things outside my control.",
        "There are other groups where I might fit even better."]),
    ("I passed, but just barely, so it doesn't count.", "discounting_positives", [
        "A pass is a pass, and I got through it.",
        "Passing a hard course is something to acknowledge.",
        "I can learn from this to feel more prepared next time."]),
    ("I can't handle university, I'm going to drop out.", "catastrophizing", [
        "Feeling overwhelmed right now doesn't mean I can't handle it.",
        "There's support available, like study advisors, before deciding anything big.",
        "I can take this week one day at a time and see how it goes."]),
    ("I should always be in a good mood around my friends.", "should_statements", [
        "Real friends don't expect me to be happy all the time.",
        "Being honest about a bad day can bring people closer.",
        "I'm allowed to have ups and downs like everyone else."]),
    ("Since I didn't get the top internship, my CV is worthless.", "all_or_nothing", [
        "Not getting one internship doesn't make my CV worthless.",
        "Many good opportunities aren't the most famous ones.",
        "I can ask for feedback and keep applying."]),
    ("I yelled at my sister, I'm a horrible person.", "labeling", [
        "I made a mistake in a heated moment; that doesn't make me horrible.",
        "I can apologise and talk with her when we're both calmer.",
        "Caring about how I treated her shows I'm not a horrible person."]),
    ("My study plan fell apart on day one, so planning is pointless for me.", "all_or_nothing", [
        "A plan that slips isn't useless; it can be adjusted.",
        "Plans usually need a few tries to fit real life.",
        "I can make tomorrow's plan smaller and more realistic."]),
    ("I feel guilty for taking a day off, so I must be falling behind.", "emotional_reasoning", [
        "Guilt doesn't prove I'm falling behind.",
        "A day off can help me come back with more energy.",
        "I can check my actual progress instead of trusting the guilt."]),
    ("My teammate got praised and I didn't, so the boss thinks my work is bad.", "mind_reading", [
        "Praise for someone else doesn't mean criticism of me.",
        "My boss might not have mentioned my work for unrelated reasons.",
        "I can ask for feedback if I want to know where I stand."]),
    ("I always choose the wrong courses.", "overgeneralizing", [
        "I'm thinking of the courses I disliked and forgetting the ones I enjoyed.",
        "Choosing courses involves guesswork for everyone.",
        "I can talk to students who took a course before choosing next time."]),
    ("If I go to the party, I'll have nothing to say and it'll be awful.", "fortune_telling", [
        "I can't know how it will go until I try.",
        "I could prepare a few easy questions to ask people.",
        "I can leave early if it isn't enjoyable; it's not all or nothing."]),
    ("I haven't heard back from the job, so they definitely rejected me.", "fortune_telling", [
        "Hiring processes often take longer than expected.",
        "No answer yet is just no answer yet.",
        "I can send a polite follow-up email after a week or two."]),
]
