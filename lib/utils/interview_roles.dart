class InterviewRoles {
  static final Map<String, List<String>> categories = {
    'IT & Engineering': [
      'Software Engineer', 'Frontend Developer', 'Backend Developer',
      'Full Stack Developer', 'Mobile Developer', 'Web Developer',
      'DevOps Engineer', 'QA Engineer', 'Data Scientist',
      'Data Analyst', 'Data Engineer', 'Cloud Engineer',
      'Machine Learning Engineer', 'Cybersecurity Analyst',
      'IT Support Specialist', 'Technical Writer',
      'UI/UX Designer', 'Product Manager', 'Scrum Master',
      'Software Tester', 'System Analyst', 'ERP Consultant',
      'IT Consultant',
    ],
    'Finance': [
      'Financial Analyst', 'Investment Analyst', 'Risk Analyst',
      'Banking Officer', 'Credit Analyst', 'Fintech Product Manager',
      'Financial Advisor', 'Accountant', 'Tax Consultant',
      'Auditor', 'Treasury Analyst', 'Compliance Officer',
      'Finance Manager',
    ],
    'Business & Marketing': [
      'Business Analyst', 'Sales Executive', 'Digital Marketing Specialist',
      'SEO Specialist', 'Brand Manager', 'Content Strategist',
      'Social Media Manager', 'Customer Success Manager',
      'Business Development Executive', 'Partnership Manager',
      'Market Research Analyst',
    ],
    'Creative & Design': [
      'Graphic Designer', 'Illustrator', 'Animator',
      'Video Editor', 'Photographer', 'Cinematographer',
      'Creative Director', 'Art Director', 'UI Designer',
      'Fashion Designer', 'Interior Designer', '3D Artist',
    ],
    'Health & Science': [
      'Medical Doctor', 'Nurse', 'Pharmacist',
      'Nutritionist', 'Clinical Research Associate', 'Medical Lab Analyst',
      'Public Health Officer', 'Psychologist',
      'Health Informatics Specialist', 'Biomedical Engineer',
    ],
    'Education': [
      'Lecturer', 'Teacher', 'Research Assistant',
      'Curriculum Developer', 'Education Consultant',
      'Private Tutor', 'Instructional Designer',
    ],
    'Other': [
      'Logistics Coordinator', 'HR Generalist', 'Recruiter',
      'Legal Officer', 'Hotel Manager', 'Chef',
      // You can add other roles that don't fit in major categories here
    ]
  };

  static List<String> getAllRoles() {
    final allRoles = <String>[];
    for (final category in categories.values) {
      allRoles.addAll(category);
    }
    return allRoles..sort();
  }
}