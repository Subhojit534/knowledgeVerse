// GENERATED FROM SQL SEED DATA - KNOWLEDGEVERSE CURRICULUM
import '../models/learning_models.dart';

class SeedClass {
  final String id;
  final String name;
  final String board;
  const SeedClass({required this.id, required this.name, required this.board});
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'board': board};
}

class SeedTopic {
  final String id;
  final String name;
  final String subject;
  final String grade;
  final String description;
  final List<MCQuestion> questions;
  const SeedTopic({
    required this.id,
    required this.name,
    required this.subject,
    required this.grade,
    required this.description,
    required this.questions,
  });
}

abstract final class CurriculumSeedCatalog {
  static const List<SeedClass> classes = [
    SeedClass(id: '00000010-0003-0000-0000-000000000000', name: 'Class 10', board: 'BSEB'),
    SeedClass(id: '00000010-0001-0000-0000-000000000000', name: 'Class 10', board: 'CBSE'),
    SeedClass(id: '00000010-0005-0000-0000-000000000000', name: 'Class 10', board: 'DBSE'),
    SeedClass(id: '00000010-0002-0000-0000-000000000000', name: 'Class 10', board: 'ICSE'),
    SeedClass(id: '00000010-0004-0000-0000-000000000000', name: 'Class 10', board: 'WBBSE'),
    SeedClass(id: '00000011-0003-0000-0000-000000000000', name: 'Class 11', board: 'BSEB'),
    SeedClass(id: '00000011-0001-0000-0000-000000000000', name: 'Class 11', board: 'CBSE'),
    SeedClass(id: '00000011-0005-0000-0000-000000000000', name: 'Class 11', board: 'DBSE'),
    SeedClass(id: '00000011-0002-0000-0000-000000000000', name: 'Class 11', board: 'ICSE'),
    SeedClass(id: '00000011-0004-0000-0000-000000000000', name: 'Class 11', board: 'WBBSE'),
    SeedClass(id: '00000012-0003-0000-0000-000000000000', name: 'Class 12', board: 'BSEB'),
    SeedClass(id: '00000012-0001-0000-0000-000000000000', name: 'Class 12', board: 'CBSE'),
    SeedClass(id: '00000012-0005-0000-0000-000000000000', name: 'Class 12', board: 'DBSE'),
    SeedClass(id: '00000012-0002-0000-0000-000000000000', name: 'Class 12', board: 'ICSE'),
    SeedClass(id: '00000012-0004-0000-0000-000000000000', name: 'Class 12', board: 'WBBSE'),
    SeedClass(id: '00000005-0003-0000-0000-000000000000', name: 'Class 5', board: 'BSEB'),
    SeedClass(id: '00000005-0001-0000-0000-000000000000', name: 'Class 5', board: 'CBSE'),
    SeedClass(id: '00000005-0005-0000-0000-000000000000', name: 'Class 5', board: 'DBSE'),
    SeedClass(id: '00000005-0002-0000-0000-000000000000', name: 'Class 5', board: 'ICSE'),
    SeedClass(id: '00000005-0004-0000-0000-000000000000', name: 'Class 5', board: 'WBBSE'),
    SeedClass(id: '00000006-0003-0000-0000-000000000000', name: 'Class 6', board: 'BSEB'),
    SeedClass(id: '00000006-0001-0000-0000-000000000000', name: 'Class 6', board: 'CBSE'),
    SeedClass(id: '00000006-0005-0000-0000-000000000000', name: 'Class 6', board: 'DBSE'),
    SeedClass(id: '00000006-0002-0000-0000-000000000000', name: 'Class 6', board: 'ICSE'),
    SeedClass(id: '00000006-0004-0000-0000-000000000000', name: 'Class 6', board: 'WBBSE'),
    SeedClass(id: '00000007-0003-0000-0000-000000000000', name: 'Class 7', board: 'BSEB'),
    SeedClass(id: '00000007-0001-0000-0000-000000000000', name: 'Class 7', board: 'CBSE'),
    SeedClass(id: '00000007-0005-0000-0000-000000000000', name: 'Class 7', board: 'DBSE'),
    SeedClass(id: '00000007-0002-0000-0000-000000000000', name: 'Class 7', board: 'ICSE'),
    SeedClass(id: '00000007-0004-0000-0000-000000000000', name: 'Class 7', board: 'WBBSE'),
    SeedClass(id: '00000008-0003-0000-0000-000000000000', name: 'Class 8', board: 'BSEB'),
    SeedClass(id: '00000008-0001-0000-0000-000000000000', name: 'Class 8', board: 'CBSE'),
    SeedClass(id: '00000008-0005-0000-0000-000000000000', name: 'Class 8', board: 'DBSE'),
    SeedClass(id: '00000008-0002-0000-0000-000000000000', name: 'Class 8', board: 'ICSE'),
    SeedClass(id: '00000008-0004-0000-0000-000000000000', name: 'Class 8', board: 'WBBSE'),
    SeedClass(id: '00000009-0003-0000-0000-000000000000', name: 'Class 9', board: 'BSEB'),
    SeedClass(id: '00000009-0001-0000-0000-000000000000', name: 'Class 9', board: 'CBSE'),
    SeedClass(id: '00000009-0005-0000-0000-000000000000', name: 'Class 9', board: 'DBSE'),
    SeedClass(id: '00000009-0002-0000-0000-000000000000', name: 'Class 9', board: 'ICSE'),
    SeedClass(id: '00000009-0004-0000-0000-000000000000', name: 'Class 9', board: 'WBBSE'),
  ];

  static final List<SeedTopic> topics = [
    SeedTopic(
      id: 'b0000007-0003-0000-0000-000000000022',
      name: 'Atmosphere & Water Circulation',
      subject: 'Social Science',
      grade: 'Class 7',
      description: 'Hydrological cycle, ocean tides, atmospheric pressure',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Which gas forms the largest constituent of the Earth atmosphere, accounting for roughly 78 percent by volume?',
          options: ['Nitrogen', 'Oxygen', 'Carbon dioxide', 'Argon'],
          correctIndex: 0,
          explanation: 'Correct answer is Nitrogen.',
        ),
        MCQuestion(
          id: 2,
          question: 'Which lowest atmospheric layer extends up to about 13 km where almost all rainfall, fog, and weather occur?',
          options: ['Troposphere', 'Stratosphere', 'Mesosphere', 'Thermosphere'],
          correctIndex: 0,
          explanation: 'Correct answer is Troposphere.',
        ),
        MCQuestion(
          id: 3,
          question: 'Why is the stratosphere considered ideal for flying commercial passenger jet aeroplanes?',
          options: ['It is largely devoid of clouds and turbulent convective weather phenomena', 'It contains dense oxygen gas facilitating combustion without turbines', 'It has zero gravitational pull allowing aircraft to float effortlessly', 'It experiences strong downward gravitational winds preventing stalls'],
          correctIndex: 0,
          explanation: 'Correct answer is It is largely devoid of clouds and turbulent convective weather phenomena.',
        ),
        MCQuestion(
          id: 4,
          question: 'Name the meteorological instrument fitted with an arrow used to indicate the exact direction of prevailing winds.',
          options: ['Wind vane', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Wind vane.',
        ),
        MCQuestion(
          id: 5,
          question: 'What are the trade winds, westerlies, and easterlies that blow consistently throughout the year termed?',
          options: ['Permanent or planetary winds', 'Seasonal monsoon winds', 'Local breeze winds', 'Cyclonic gust winds'],
          correctIndex: 0,
          explanation: 'Correct answer is Permanent or planetary winds.',
        ),
        MCQuestion(
          id: 6,
          question: 'What is the searing, scorching local summer wind blowing across the northern plains of India called?',
          options: ['Loo', 'Mistral', 'Chinook', 'Harmattan'],
          correctIndex: 0,
          explanation: 'Correct answer is Loo.',
        ),
        MCQuestion(
          id: 7,
          question: 'What are exceptionally high ocean tides occurring when the Sun, Moon, and Earth align in a straight line called?',
          options: ['Spring tides', 'Neap tides', 'Diurnal tides', 'Ebb currents'],
          correctIndex: 0,
          explanation: 'Correct answer is Spring tides.',
        ),
        MCQuestion(
          id: 8,
          question: 'When the Moon is in its first or third quarter, the gravitational forces of the Sun and Moon act perpendicular to each other causing:',
          options: ['Neap tides', 'Spring tides', 'Tsunami surges', 'Equatorial swells'],
          correctIndex: 0,
          explanation: 'Correct answer is Neap tides.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000011-0003-0000-0000-000000000051',
      name: 'Calculus & Combinatorics',
      subject: 'Mathematics',
      grade: 'Class 11',
      description: 'Limits, derivatives, permutations, combinations, binomial theorem',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Evaluate the trigonometric limit: lim (x -> 0) [(1 - cos(x)) / x^2].',
          options: ['1/2', '1', '0', '2'],
          correctIndex: 0,
          explanation: 'Correct answer is 1/2.',
        ),
        MCQuestion(
          id: 2,
          question: 'What is the derivative of f(x) = sin(x) with respect to x?',
          options: ['cos(x)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is cos(x).',
        ),
        MCQuestion(
          id: 3,
          question: 'What is the first derivative of f(x) = x * ln(x) for x > 0 with respect to x?',
          options: ['1 + ln(x)', 'ln(x)', '1 / x', 'x + ln(x)'],
          correctIndex: 0,
          explanation: 'Correct answer is 1 + ln(x).',
        ),
        MCQuestion(
          id: 4,
          question: 'Evaluate the algebraic limit: lim (x -> 2) [(x^2 - 4) / (x - 2)].',
          options: ['4', '2', '0', 'Undefined'],
          correctIndex: 0,
          explanation: 'Correct answer is 4.',
        ),
        MCQuestion(
          id: 5,
          question: 'What is the derivative of f(x) = cot(x) with respect to x?',
          options: ['-csc^2(x)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is -csc^2(x).',
        ),
        MCQuestion(
          id: 6,
          question: 'Evaluate the limit at infinity: lim (x -> infinity) [(3x^2 + 5x) / (2x^2 - 7)].',
          options: ['3/2', '5/2', '0', 'Infinity'],
          correctIndex: 0,
          explanation: 'Correct answer is 3/2.',
        ),
        MCQuestion(
          id: 7,
          question: 'If y = sqrt(x), what is the value of dy/dx evaluated at x = 4?',
          options: ['1/4 (0.25)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 1/4 (0.25).',
        ),
        MCQuestion(
          id: 8,
          question: 'What is the value of the exponential limit: lim (x -> 0) [(e^x - 1) / x]?',
          options: ['1', 'e', '0', 'Infinity'],
          correctIndex: 0,
          explanation: 'Correct answer is 1.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000011-0004-0000-0000-000000000052',
      name: 'Cell Biology & Physiology',
      subject: 'Biology',
      grade: 'Class 11',
      description: 'Mitosis, meiosis, Calvin cycle, Krebs cycle, action potential',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Where in chloroplasts do the light-dependent photochemical reactions of photosynthesis occur?',
          options: ['Thylakoid membranes (grana)', 'Stroma matrix', 'Inner chloroplast envelope', 'Periplastidial space'],
          correctIndex: 0,
          explanation: 'Correct answer is Thylakoid membranes (grana).',
        ),
        MCQuestion(
          id: 2,
          question: 'What is the peak absorption wavelength of the reaction center chlorophyll a in Photosystem I (PSI)?',
          options: ['700 nm (P700)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 700 nm (P700).',
        ),
        MCQuestion(
          id: 3,
          question: 'What is the first stable 3-carbon intermediate compound formed during carbon fixation in C3 plants?',
          options: ['3-Phosphoglyceric acid (3-PGA)', 'Oxaloacetic acid (OAA)', 'Phosphoenolpyruvate (PEP)', 'Glyceraldehyde 3-phosphate (G3P)'],
          correctIndex: 0,
          explanation: 'Correct answer is 3-Phosphoglyceric acid (3-PGA).',
        ),
        MCQuestion(
          id: 4,
          question: 'In C4 plants, initial atmospheric CO2 fixation takes place in which specific leaf cells?',
          options: ['Mesophyll cells', 'Bundle sheath cells', 'Epidermal cells', 'Xylem parenchyma cells'],
          correctIndex: 0,
          explanation: 'Correct answer is Mesophyll cells.',
        ),
        MCQuestion(
          id: 5,
          question: 'What are the two 3-carbon end-product molecules produced by glycolysis from one molecule of glucose?',
          options: ['Pyruvic acid (Pyruvate)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Pyruvic acid (Pyruvate).',
        ),
        MCQuestion(
          id: 6,
          question: 'Which metal ions are indispensable for the water-splitting complex during photolysis in Photosystem II?',
          options: ['Manganese (Mn) and Chlorine (Cl)', 'Magnesium (Mg) and Iron (Fe)', 'Copper (Cu) and Zinc (Zn)', 'Molybdenum (Mo) and Cobalt (Co)'],
          correctIndex: 0,
          explanation: 'Correct answer is Manganese (Mn) and Chlorine (Cl).',
        ),
        MCQuestion(
          id: 7,
          question: 'What is the Respiratory Quotient (RQ) when glucose or starch is completely oxidized in aerobic respiration?',
          options: ['1.0', '0.7', '0.9', 'Infinity'],
          correctIndex: 0,
          explanation: 'Correct answer is 1.0.',
        ),
        MCQuestion(
          id: 8,
          question: 'How many ATP molecules are synthesized on average when one molecule of NADH is oxidized in the mitochondrial ETC?',
          options: ['3 (or approx 2.5) ATP molecules', '2 (or approx 1.5) ATP molecules', '1 ATP molecule', '4 ATP molecules'],
          correctIndex: 0,
          explanation: 'Correct answer is 3 (or approx 2.5) ATP molecules.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000011-0002-0000-0000-000000000050',
      name: 'Chemical Bonding & Equilibrium',
      subject: 'Chemistry',
      grade: 'Class 11',
      description: 'Hybridization, molecular orbital theory, Le Chatelier principle, pH buffer',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'According to VSEPR theory, what is the geometric shape of the ammonia (NH3) molecule?',
          options: ['Trigonal pyramidal', 'Trigonal planar', 'Tetrahedral', 'T-shaped'],
          correctIndex: 0,
          explanation: 'Correct answer is Trigonal pyramidal.',
        ),
        MCQuestion(
          id: 2,
          question: 'What is the hybridization of the central sulfur atom in sulfur hexafluoride (SF6)?',
          options: ['sp3d2', 'sp3d', 'sp3', 'dsp2'],
          correctIndex: 0,
          explanation: 'Correct answer is sp3d2.',
        ),
        MCQuestion(
          id: 3,
          question: 'According to Molecular Orbital Theory, what is the bond order of the dinitrogen molecule (N2)?',
          options: ['3 (Triple bond)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 3 (Triple bond).',
        ),
        MCQuestion(
          id: 4,
          question: 'What is the molecular geometry and bond angle in boron trifluoride (BF3)?',
          options: ['Trigonal planar with 120 degree bond angles', 'Trigonal pyramidal with 107 degree bond angles', 'T-shaped with 90 degree bond angles', 'Linear with 180 degree bond angles'],
          correctIndex: 0,
          explanation: 'Correct answer is Trigonal planar with 120 degree bond angles.',
        ),
        MCQuestion(
          id: 5,
          question: 'How many sigma (sigma) and pi (pi) bonds are present in an ethyne (acetylene, C2H2) molecule?',
          options: ['3 sigma bonds and 2 pi bonds', '2 sigma bonds and 3 pi bonds', '4 sigma bonds and 1 pi bond', '5 sigma bonds and 0 pi bonds'],
          correctIndex: 0,
          explanation: 'Correct answer is 3 sigma bonds and 2 pi bonds.',
        ),
        MCQuestion(
          id: 6,
          question: 'The paramagnetism of the oxygen molecule (O2) with two unpaired electrons is successfully explained by which theory?',
          options: ['Molecular Orbital Theory (MOT)', 'Valence Bond Theory (VBT)', 'Lewis Octet Theory', 'Resonance Theory'],
          correctIndex: 0,
          explanation: 'Correct answer is Molecular Orbital Theory (MOT).',
        ),
        MCQuestion(
          id: 7,
          question: 'What is the formal charge on the central oxygen atom in the ozone (O3) resonance structure?',
          options: ['+1', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is +1.',
        ),
        MCQuestion(
          id: 8,
          question: 'Why is the H-O-H bond angle in water (H2O) 104.5 degrees rather than the tetrahedral angle of 109.5 degrees?',
          options: ['Lone pair - lone pair repulsion is greater than bond pair - bond pair repulsion', 'High electronegativity of hydrogen attracts oxygen core electrons', 'Steric hindrance between large hydrogen atoms pushes them closer', 'Involvement of d-orbitals in oxygen sp3 hybridization'],
          correctIndex: 0,
          explanation: 'Correct answer is Lone pair - lone pair repulsion is greater than bond pair - bond pair repulsion.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000010-0002-0000-0000-000000000043',
      name: 'Chemical Reactions & Carbon Compounds',
      subject: 'Science',
      grade: 'Class 10',
      description: 'Redox reactions, homologous series, functional groups, saponification',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What type of chemical reaction is represented by: 2Mg(s) + O2(g) -> 2MgO(s)?',
          options: ['Combination reaction', 'Decomposition reaction', 'Displacement reaction', 'Double displacement reaction'],
          correctIndex: 0,
          explanation: 'Correct answer is Combination reaction.',
        ),
        MCQuestion(
          id: 2,
          question: 'Heating of limestone (CaCO3 -> CaO + CO2) is an example of which reaction?',
          options: ['Thermal decomposition reaction', 'Combination reaction', 'Photochemical reaction', 'Neutralization reaction'],
          correctIndex: 0,
          explanation: 'Correct answer is Thermal decomposition reaction.',
        ),
        MCQuestion(
          id: 3,
          question: 'What happens when dilute hydrochloric acid is added to zinc granules?',
          options: ['Hydrogen gas and zinc chloride are produced', 'Chlorine gas and zinc hydroxide are produced', 'No chemical reaction occurs', 'Zinc oxide and water are produced'],
          correctIndex: 0,
          explanation: 'Correct answer is Hydrogen gas and zinc chloride are produced.',
        ),
        MCQuestion(
          id: 4,
          question: 'In the redox reaction: MnO2 + 4HCl -> MnCl2 + 2H2O + Cl2, which substance is oxidized?',
          options: ['HCl', 'MnO2', 'MnCl2', 'H2O'],
          correctIndex: 0,
          explanation: 'Correct answer is HCl.',
        ),
        MCQuestion(
          id: 5,
          question: 'Which of the following processes is endothermic in nature?',
          options: ['Decomposition of ferrous sulphate crystals', 'Burning of natural gas', 'Cellular respiration', 'Slaking of quicklime with water'],
          correctIndex: 0,
          explanation: 'Correct answer is Decomposition of ferrous sulphate crystals.',
        ),
        MCQuestion(
          id: 6,
          question: 'What type of reaction occurs when aqueous lead nitrate is mixed with potassium iodide solution?',
          options: ['Precipitation and double displacement reaction', 'Combination reaction', 'Thermal decomposition reaction', 'Simple displacement reaction'],
          correctIndex: 0,
          explanation: 'Correct answer is Precipitation and double displacement reaction.',
        ),
        MCQuestion(
          id: 7,
          question: 'Fatty and oily food items develop an unpleasant smell and taste over time primarily due to:',
          options: ['Aerial oxidation of fats and oils', 'Reduction of carbohydrates', 'Hydrolysis of proteins', 'Evaporation of moisture content'],
          correctIndex: 0,
          explanation: 'Correct answer is Aerial oxidation of fats and oils.',
        ),
        MCQuestion(
          id: 8,
          question: 'When copper powder is heated in air, its surface turns black due to the formation of:',
          options: ['Copper(II) oxide (CuO)', 'Copper(I) oxide (Cu2O)', 'Basic copper carbonate', 'Copper sulphate'],
          correctIndex: 0,
          explanation: 'Correct answer is Copper(II) oxide (CuO).',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000007-0003-0000-0000-000000000021',
      name: 'Delhi Sultanate & Mughals',
      subject: 'Social Science',
      grade: 'Class 7',
      description: 'Raziya Sultan, Alauddin Khalji, Akbar administrative reforms',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Who was the Turkish commander that founded the Slave (Mamluk) Dynasty in Delhi in 1206 CE?',
          options: ['Qutb-ud-din Aibak', 'Shams-ud-din Iltutmish', 'Ghiyas-ud-din Balban', 'Alauddin Khalji'],
          correctIndex: 0,
          explanation: 'Correct answer is Qutb-ud-din Aibak.',
        ),
        MCQuestion(
          id: 2,
          question: 'Which Delhi Sultan notoriously transferred his imperial capital from Delhi to Daulatabad (Devagiri) in 1327 CE?',
          options: ['Muhammad bin Tughlaq', 'Firoz Shah Tughlaq', 'Ghiyas-ud-din Tughlaq', 'Bahlul Lodi'],
          correctIndex: 0,
          explanation: 'Correct answer is Muhammad bin Tughlaq.',
        ),
        MCQuestion(
          id: 3,
          question: 'What title was assigned to military commanders entrusted with revenue administration of territories (Iqtas) during the Sultanate?',
          options: ['Muqti or Iqtadar', 'Mansabdar', 'Subadar', 'Kotwal'],
          correctIndex: 0,
          explanation: 'Correct answer is Muqti or Iqtadar.',
        ),
        MCQuestion(
          id: 4,
          question: 'In which historic battle in 1526 did Babur defeat Ibrahim Lodi, bringing an end to the Delhi Sultanate?',
          options: ['First Battle of Panipat', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is First Battle of Panipat.',
        ),
        MCQuestion(
          id: 5,
          question: 'What agricultural tax on peasant crop yield (roughly amounting to 50 percent) was strictly levied by Alauddin Khalji?',
          options: ['Kharaj', 'Jizya', 'Zakat', 'Chauth'],
          correctIndex: 0,
          explanation: 'Correct answer is Kharaj.',
        ),
        MCQuestion(
          id: 6,
          question: 'Which thirteenth-century Persian court chronicler praised Raziya Sultan for being more competent than her brothers?',
          options: ['Minhaj-i Siraj', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Minhaj-i Siraj.',
        ),
        MCQuestion(
          id: 7,
          question: 'What were the administrative provinces called in the Mughal Empire under Emperor Akbar?',
          options: ['Subas', 'Sarkars', 'Parganas', 'Mahals'],
          correctIndex: 0,
          explanation: 'Correct answer is Subas.',
        ),
        MCQuestion(
          id: 8,
          question: 'Name the high-ranking imperial officer who served as the military paymaster in Akbar administration.',
          options: ['Mir Bakshi', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Mir Bakshi.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000006-0003-0000-0000-000000000013',
      name: 'Early Civilizations & Ashoka',
      subject: 'Social Science',
      grade: 'Class 6',
      description: 'Harappan urbanism, Mauryan Empire, and Ashokan edicts',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Name the illustrious founder of the Mauryan Empire who was the grandfather of Emperor Ashoka.',
          options: ['Chandragupta Maurya', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Chandragupta Maurya.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000006-0003-0000-0000-000000000014',
      name: 'Earth Domains & Diversity',
      subject: 'Social Science',
      grade: 'Class 6',
      description: 'Atmosphere, hydrosphere, government, and equality',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Which major relief landform is described as an elevated flat-topped tableland rising steeply above surrounding plains?',
          options: ['Plateau', 'Mountain range', 'River valley', 'Coastal plain'],
          correctIndex: 0,
          explanation: 'Correct answer is Plateau.',
        ),
        MCQuestion(
          id: 2,
          question: 'What narrow global zone of contact encompasses portions of the lithosphere, hydrosphere, and atmosphere where living organisms exist?',
          options: ['Biosphere', 'Exosphere', 'Cryosphere', 'Asthenosphere'],
          correctIndex: 0,
          explanation: 'Correct answer is Biosphere.',
        ),
        MCQuestion(
          id: 3,
          question: 'Which stratospheric gas shield filters out carcinogenic ultraviolet (UV) radiation coming from the Sun?',
          options: ['Ozone layer', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Ozone layer.',
        ),
        MCQuestion(
          id: 4,
          question: 'What is the highest mountain peak above sea level on Earth, towering in the Mahalangur Himal sub-range?',
          options: ['Mount Everest', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Mount Everest.',
        ),
        MCQuestion(
          id: 5,
          question: 'What core democratic principle guarantees that every citizen aged 18 or above has the constitutional right to vote without discrimination?',
          options: ['Universal Adult Franchise (Suffrage)', 'Dynastic Succession', 'Property Qualification', 'Proportional Representation'],
          correctIndex: 0,
          explanation: 'Correct answer is Universal Adult Franchise (Suffrage).',
        ),
        MCQuestion(
          id: 6,
          question: 'What is the customary statutory term of office for the Lok Sabha (Lower House of Parliament) in India before fresh elections?',
          options: ['5 years', '3 years', '4 years', '6 years'],
          correctIndex: 0,
          explanation: 'Correct answer is 5 years.',
        ),
        MCQuestion(
          id: 7,
          question: 'Which grassroots elected body forms the primary tier of rural local self-governance in Indian villages?',
          options: ['Gram Panchayat', 'Zila Parishad', 'Panchayat Samiti', 'Municipal Council'],
          correctIndex: 0,
          explanation: 'Correct answer is Gram Panchayat.',
        ),
        MCQuestion(
          id: 8,
          question: 'Which independent branch of democratic government upholds fundamental rights and adjudicates constitutional disputes?',
          options: ['Judiciary', 'Executive', 'Legislature', 'Civil Service Bureaucracy'],
          correctIndex: 0,
          explanation: 'Correct answer is Judiciary.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0002-0000-0000-000000000028',
      name: 'Forces, Pressure & Sound',
      subject: 'Science',
      grade: 'Class 8',
      description: 'Atmospheric pressure, friction reduction, sound frequency',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the standard International System (SI) unit of physical force?',
          options: ['Newton (N)', 'Pascal (Pa)', 'Joule (J)', 'Watt (W)'],
          correctIndex: 0,
          explanation: 'Correct answer is Newton (N).',
        ),
        MCQuestion(
          id: 2,
          question: 'Which of the following forces represents a direct contact mechanical force?',
          options: ['Muscular force', 'Gravitational force', 'Electrostatic force', 'Magnetic force'],
          correctIndex: 0,
          explanation: 'Correct answer is Muscular force.',
        ),
        MCQuestion(
          id: 3,
          question: 'In classical physics, how is mechanical pressure mathematically defined?',
          options: ['Thrust force acting per unit surface area', 'Force multiplied by the contact area', 'Mass per unit volume of an object', 'Work accomplished per unit of time'],
          correctIndex: 0,
          explanation: 'Correct answer is Thrust force acting per unit surface area.',
        ),
        MCQuestion(
          id: 4,
          question: 'What contact force consistently opposes the relative sliding or rolling motion between two surfaces?',
          options: ['Friction', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Friction.',
        ),
        MCQuestion(
          id: 5,
          question: 'If a perpendicular force of 400 N is exerted across an area of 0.02 m^2, calculate the resulting pressure.',
          options: ['20,000 Pascals', '8,000 Pascals', '4,000 Pascals', '800 Pascals'],
          correctIndex: 0,
          explanation: 'Correct answer is 20,000 Pascals.',
        ),
        MCQuestion(
          id: 6,
          question: 'What non-contact force is exerted between stationary electrical charges on rubbed insulating objects?',
          options: ['Electrostatic force', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Electrostatic force.',
        ),
        MCQuestion(
          id: 7,
          question: 'What is the normal audible frequency range of acoustic waves perceptible to the average human ear?',
          options: ['20 Hz to 20,000 Hz', '5 Hz to 500 Hz', '100 Hz to 100,000 Hz', '10 Hz to 1,000 Hz'],
          correctIndex: 0,
          explanation: 'Correct answer is 20 Hz to 20,000 Hz.',
        ),
        MCQuestion(
          id: 8,
          question: 'The physiological loudness or intensity of a sound wave is primarily determined by its:',
          options: ['Amplitude of vibration', 'Wave frequency', 'Acoustic pitch', 'Speed in air'],
          correctIndex: 0,
          explanation: 'Correct answer is Amplitude of vibration.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000007-0002-0000-0000-000000000020',
      name: 'Heat Transfer & Circulatory System',
      subject: 'Science',
      grade: 'Class 7',
      description: 'Conduction, convection, radiation, heart and blood',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Which fundamental mode of heat transmission can take place through vacuum without requiring any physical medium?',
          options: ['Radiation', 'Conduction', 'Convection', 'Advection'],
          correctIndex: 0,
          explanation: 'Correct answer is Radiation.',
        ),
        MCQuestion(
          id: 2,
          question: 'In which state of matter does thermal energy transfer take place predominantly by conduction?',
          options: ['Solids', 'Liquids', 'Gases', 'Plasma'],
          correctIndex: 0,
          explanation: 'Correct answer is Solids.',
        ),
        MCQuestion(
          id: 3,
          question: 'Why does a sea breeze develop during daytime along coastal land masses?',
          options: ['Land warms up faster than sea water creating a low pressure zone over land', 'Sea water warms up faster than coastal land creating a vacuum above sea', 'Dense cold air over coastal mountains descends directly into the ocean', 'The Moon gravitational tidal pull displaces air masses inland'],
          correctIndex: 0,
          explanation: 'Correct answer is Land warms up faster than sea water creating a low pressure zone over land.',
        ),
        MCQuestion(
          id: 4,
          question: 'What is the standard measurement temperature range of a human clinical thermometer in degrees Celsius?',
          options: ['35 degrees C to 42 degrees C', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 35 degrees C to 42 degrees C.',
        ),
        MCQuestion(
          id: 5,
          question: 'Why do thick woollen garments protect the human body effectively from severe winter cold?',
          options: ['Wool fibres trap stationary air which acts as an excellent insulator of heat', 'Wool fibres continuously generate internal chemical calories', 'Wool actively absorbs infrared electromagnetic radiation from surroundings', 'Wool speeds up convection currents between clothing layers'],
          correctIndex: 0,
          explanation: 'Correct answer is Wool fibres trap stationary air which acts as an excellent insulator of heat.',
        ),
        MCQuestion(
          id: 6,
          question: 'Name the heat transfer process occurring in fluids where heated warmer fluid rises and cooler denser fluid sinks.',
          options: ['Convection', 'Conduction', 'Radiation', 'Insulation'],
          correctIndex: 0,
          explanation: 'Correct answer is Convection.',
        ),
        MCQuestion(
          id: 7,
          question: 'How many distinct muscular pumping chambers exist in the human heart?',
          options: ['4 chambers', '3 chambers', '2 chambers', '6 chambers'],
          correctIndex: 0,
          explanation: 'Correct answer is 4 chambers.',
        ),
        MCQuestion(
          id: 8,
          question: 'Which cellular component of blood acts as microscopic soldiers defending against disease-causing germs?',
          options: ['White Blood Cells (WBCs)', 'Red Blood Cells (RBCs)', 'Blood platelets (Thrombocytes)', 'Blood plasma proteins'],
          correctIndex: 0,
          explanation: 'Correct answer is White Blood Cells (WBCs).',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0003-0000-0000-000000000029',
      name: 'Indian Constitution & Secularism',
      subject: 'Social Science',
      grade: 'Class 8',
      description: 'Fundamental Rights, separation of powers, judicial review',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Who was the Chairman of the Drafting Committee of the Constituent Assembly, known as the Father of the Indian Constitution?',
          options: ['Dr. B.R. Ambedkar', 'Mahatma Gandhi', 'Jawaharlal Nehru', 'Dr. Rajendra Prasad'],
          correctIndex: 0,
          explanation: 'Correct answer is Dr. B.R. Ambedkar.',
        ),
        MCQuestion(
          id: 2,
          question: 'Which Fundamental Right in the Constitution of India guarantees the freedom of conscience and religious practice to all individuals?',
          options: ['Right to Freedom of Religion (Articles 25-28)', 'Right to Equality (Articles 14-18)', 'Cultural and Educational Rights (Articles 29-30)', 'Right against Exploitation (Articles 23-24)'],
          correctIndex: 0,
          explanation: 'Correct answer is Right to Freedom of Religion (Articles 25-28).',
        ),
        MCQuestion(
          id: 3,
          question: 'In which calendar year did the Constitution of India formally come into operational effect on Republic Day?',
          options: ['1950', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 1950.',
        ),
        MCQuestion(
          id: 4,
          question: 'What constitutional term designates the existence of more than one level of government (Union and State) in India?',
          options: ['Federalism', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Federalism.',
        ),
        MCQuestion(
          id: 5,
          question: 'Which judicial institution stands at the apex of the integrated judicial hierarchy in the Republic of India?',
          options: ['Supreme Court of India', 'State High Court', 'District and Sessions Court', 'National Green Tribunal'],
          correctIndex: 0,
          explanation: 'Correct answer is Supreme Court of India.',
        ),
        MCQuestion(
          id: 6,
          question: 'In which metropolitan city is the permanent seat of the Supreme Court of India located?',
          options: ['New Delhi', 'Mumbai', 'Kolkata', 'Chennai'],
          correctIndex: 0,
          explanation: 'Correct answer is New Delhi.',
        ),
        MCQuestion(
          id: 7,
          question: 'What judicial innovation devised in the early 1980s allows citizens to file cases directly on behalf of underprivileged groups?',
          options: ['Public Interest Litigation (PIL)', 'Habeas Corpus Petition', 'Caveat Petition', 'Special Leave Petition'],
          correctIndex: 0,
          explanation: 'Correct answer is Public Interest Litigation (PIL).',
        ),
        MCQuestion(
          id: 8,
          question: 'Name the highest ranking judicial official who presides over the Supreme Court of India.',
          options: ['Chief Justice of India', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Chief Justice of India.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0001-0000-0000-000000000025',
      name: 'Linear Equations & Quadrilaterals',
      subject: 'Mathematics',
      grade: 'Class 8',
      description: 'Transposition, angle sum property, parallelogram rules',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Solve the linear equation for x: 5x + 9 = 2x + 24.',
          options: ['5', '3', '7', '4'],
          correctIndex: 0,
          explanation: 'Correct answer is 5.',
        ),
        MCQuestion(
          id: 2,
          question: 'Solve for x: (2x + 1) / (3x - 2) = 5/9.',
          options: ['-19/3', '19/3', '-3/19', '7'],
          correctIndex: 0,
          explanation: 'Correct answer is -19/3.',
        ),
        MCQuestion(
          id: 3,
          question: 'Solve the decimal linear equation: 0.25(4f - 3) = 0.05(10f - 9). What is f?',
          options: ['0.6', '0.8', '1.2', '0.4'],
          correctIndex: 0,
          explanation: 'Correct answer is 0.6.',
        ),
        MCQuestion(
          id: 4,
          question: 'Solve for y: 7y - 4 = 3y + 16.',
          options: ['5', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 5.',
        ),
        MCQuestion(
          id: 5,
          question: 'The perimeter of a rectangle is 40 cm. If its length is 4 cm greater than its breadth, find the breadth.',
          options: ['8 cm', '12 cm', '10 cm', '6 cm'],
          correctIndex: 0,
          explanation: 'Correct answer is 8 cm.',
        ),
        MCQuestion(
          id: 6,
          question: 'Solve the linear equation for x: (x - 5)/3 = (x - 3)/5.',
          options: ['8', '6', '10', '4'],
          correctIndex: 0,
          explanation: 'Correct answer is 8.',
        ),
        MCQuestion(
          id: 7,
          question: 'What is the sum of the measures of the exterior angles of any convex polygon?',
          options: ['360 degrees', '180 degrees', '540 degrees', '720 degrees'],
          correctIndex: 0,
          explanation: 'Correct answer is 360 degrees.',
        ),
        MCQuestion(
          id: 8,
          question: 'A parallelogram having all four sides of equal length and diagonals perpendicular to each other is a:',
          options: ['Rhombus', 'Trapezium', 'Kite', 'Scalene quadrilateral'],
          correctIndex: 0,
          explanation: 'Correct answer is Rhombus.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000011-0001-0000-0000-000000000049',
      name: 'Mechanics & Thermodynamics',
      subject: 'Physics',
      grade: 'Class 11',
      description: 'Vectors, projectile motion, Newton laws, First & Second law of thermodynamics',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the direction of acceleration of a projectile at the highest point of its trajectory?',
          options: ['Vertically downward towards the center of Earth', 'Horizontally in the direction of motion', 'Zero since vertical velocity is zero', 'Tangential to the curved trajectory path'],
          correctIndex: 0,
          explanation: 'Correct answer is Vertically downward towards the center of Earth.',
        ),
        MCQuestion(
          id: 2,
          question: 'What is the horizontal range R of a projectile fired with speed u at an angle theta to the horizontal?',
          options: ['R = (u^2 * sin(2*theta)) / g', 'R = (u^2 * cos(2*theta)) / g', 'R = (u * sin(theta)) / (2 * g)', 'R = (u^2 * sin^2(theta)) / (2 * g)'],
          correctIndex: 0,
          explanation: 'Correct answer is R = (u^2 * sin(2*theta)) / g.',
        ),
        MCQuestion(
          id: 3,
          question: 'What is the net work done by gravitational force when a satellite completes one full circular orbit around Earth?',
          options: ['Zero (0 Joules)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Zero (0 Joules).',
        ),
        MCQuestion(
          id: 4,
          question: 'What geometrical curve describes the trajectory of a projectile moving under uniform gravity in vacuum?',
          options: ['Parabola (Parabolic trajectory)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Parabola (Parabolic trajectory).',
        ),
        MCQuestion(
          id: 5,
          question: 'What is the gravitational potential energy U of two point masses m1 and m2 separated by distance r?',
          options: ['U = - (G * m1 * m2) / r', 'U = + (G * m1 * m2) / r', 'U = - (G * m1 * m2) / r^2', 'U = + (G * m1 * m2) / r^2'],
          correctIndex: 0,
          explanation: 'Correct answer is U = - (G * m1 * m2) / r.',
        ),
        MCQuestion(
          id: 6,
          question: 'State the SI unit and approximate standard value of the universal gravitational constant G.',
          options: ['6.674 x 10^-11 N m^2 kg^-2', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 6.674 x 10^-11 N m^2 kg^-2.',
        ),
        MCQuestion(
          id: 7,
          question: 'What is the average translational kinetic energy of a single molecule of an ideal gas at absolute temperature T?',
          options: ['(3/2) * k_B * T', '(1/2) * k_B * T', '(5/2) * k_B * T', '3 * k_B * T'],
          correctIndex: 0,
          explanation: 'Correct answer is (3/2) * k_B * T.',
        ),
        MCQuestion(
          id: 8,
          question: 'Which thermodynamic state variable remains constant throughout an isothermal process?',
          options: ['Temperature (T = constant)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Temperature (T = constant).',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0001-0000-0000-000000000026',
      name: 'Mensuration & Algebraic Identities',
      subject: 'Mathematics',
      grade: 'Class 8',
      description: 'Cylinder, cone, surface area, (a+b)^2, factorisation',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Which of the following standard algebraic identities correctly represents (a - b)^2?',
          options: ['a^2 - 2ab + b^2', 'a^2 + 2ab + b^2', 'a^2 - b^2', 'a^2 - 2ab - b^2'],
          correctIndex: 0,
          explanation: 'Correct answer is a^2 - 2ab + b^2.',
        ),
        MCQuestion(
          id: 2,
          question: 'Evaluate (103)^2 by applying the identity (a + b)^2 = a^2 + 2ab + b^2.',
          options: ['10,609', '10,909', '10,309', '10,606'],
          correctIndex: 0,
          explanation: 'Correct answer is 10,609.',
        ),
        MCQuestion(
          id: 3,
          question: 'Factorise the difference of squares: 49x^2 - 36.',
          options: ['(7x - 6)(7x + 6)', '(7x - 6)^2', '(7x + 6)^2', '(49x - 6)(x + 6)'],
          correctIndex: 0,
          explanation: 'Correct answer is (7x - 6)(7x + 6).',
        ),
        MCQuestion(
          id: 4,
          question: 'Expand using the appropriate algebraic identity: (2x + 5y)^2.',
          options: ['4x^2 + 20xy + 25y^2', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 4x^2 + 20xy + 25y^2.',
        ),
        MCQuestion(
          id: 5,
          question: 'If x + 1/x = 5, calculate the value of x^2 + 1/x^2.',
          options: ['23', '25', '27', '21'],
          correctIndex: 0,
          explanation: 'Correct answer is 23.',
        ),
        MCQuestion(
          id: 6,
          question: 'Compute the product 98 * 102 by applying the identity (a - b)(a + b) = a^2 - b^2.',
          options: ['9996', '9986', '9994', '10004'],
          correctIndex: 0,
          explanation: 'Correct answer is 9996.',
        ),
        MCQuestion(
          id: 7,
          question: 'What is the formula for the curved surface area (CSA) of a right circular cylinder with radius r and height h?',
          options: ['2 * pi * r * h', 'pi * r^2 * h', '2 * pi * r * (r + h)', '4 * pi * r^2'],
          correctIndex: 0,
          explanation: 'Correct answer is 2 * pi * r * h.',
        ),
        MCQuestion(
          id: 8,
          question: 'Find the total surface area of a cube whose side edge length is 5 cm.',
          options: ['150 cm^2', '125 cm^2', '100 cm^2', '175 cm^2'],
          correctIndex: 0,
          explanation: 'Correct answer is 150 cm^2.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0002-0000-0000-000000000027',
      name: 'Microorganisms & Crop Management',
      subject: 'Science',
      grade: 'Class 8',
      description: 'Bacteria, fungi, vaccines, drip irrigation, fertilizers',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Which modern tractor-driven agricultural implement is widely used for ploughing and turning soil efficiently?',
          options: ['Cultivator', 'Sickle', 'Khurpi', 'Combine harvester'],
          correctIndex: 0,
          explanation: 'Correct answer is Cultivator.',
        ),
        MCQuestion(
          id: 2,
          question: 'Which water-saving irrigation method delivers water like artificial rain and is ideal for uneven land?',
          options: ['Sprinkler system', 'Moat (pulley system)', 'Chain pump', 'Rahat (lever system)'],
          correctIndex: 0,
          explanation: 'Correct answer is Sprinkler system.',
        ),
        MCQuestion(
          id: 3,
          question: 'What is the post-harvest agricultural process of separating edible grain seeds from husk and chaff?',
          options: ['Threshing and winnowing', 'Tilling and harrowing', 'Weeding and hoeing', 'Levelling and harrowing'],
          correctIndex: 0,
          explanation: 'Correct answer is Threshing and winnowing.',
        ),
        MCQuestion(
          id: 4,
          question: 'Name the seasonal crops sown during the monsoon season from June to September in India.',
          options: ['Kharif crops', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Kharif crops.',
        ),
        MCQuestion(
          id: 5,
          question: 'Which organic manure is prepared by utilizing earthworms to decompose biodegradable organic farm matter?',
          options: ['Vermicompost', 'Urea fertiliser', 'Superphosphate', 'Potassium chloride'],
          correctIndex: 0,
          explanation: 'Correct answer is Vermicompost.',
        ),
        MCQuestion(
          id: 6,
          question: 'Name the agricultural tool used for sowing seeds uniformly at proper depths and equal intervals.',
          options: ['Seed drill', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Seed drill.',
        ),
        MCQuestion(
          id: 7,
          question: 'Which bacterial microorganism multiplies in warm milk and promotes its curdling into yogurt?',
          options: ['Lactobacillus', 'Rhizobium', 'Bacillus anthracis', 'Streptococcus pneumoniae'],
          correctIndex: 0,
          explanation: 'Correct answer is Lactobacillus.',
        ),
        MCQuestion(
          id: 8,
          question: 'What is the biological conversion of natural sugars into alcohol and carbon dioxide by yeast called?',
          options: ['Fermentation', 'Pasteurization', 'Nitrogen fixation', 'Sterilization'],
          correctIndex: 0,
          explanation: 'Correct answer is Fermentation.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0003-0000-0000-000000000030',
      name: 'Mineral & Power Resources',
      subject: 'Social Science',
      grade: 'Class 8',
      description: 'Metallic/non-metallic minerals, thermal and solar power',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Which Asian country ranks as the leading global producer of iron ore, lead, zinc, and tin?',
          options: ['China', 'Japan', 'Indonesia', 'Malaysia'],
          correctIndex: 0,
          explanation: 'Correct answer is China.',
        ),
        MCQuestion(
          id: 2,
          question: 'What non-conventional renewable energy utilizes hydrothermal steam and heat tapped from deep within Earth magma?',
          options: ['Geothermal energy', 'Tidal energy', 'Biomass gas', 'Nuclear fission'],
          correctIndex: 0,
          explanation: 'Correct answer is Geothermal energy.',
        ),
        MCQuestion(
          id: 3,
          question: 'Name the primary reddish rock ore mined for the commercial smelting of aluminium metal.',
          options: ['Bauxite', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Bauxite.',
        ),
        MCQuestion(
          id: 4,
          question: 'What term is used for electricity generated by water rushing through high dam turbines?',
          options: ['Hydroelectricity', 'Thermal power', 'Geothermal power', 'Nuclear power'],
          correctIndex: 0,
          explanation: 'Correct answer is Hydroelectricity.',
        ),
        MCQuestion(
          id: 5,
          question: 'In which geographic region of California is the world famous tech agglomeration Silicon Valley located?',
          options: ['Santa Clara Valley', 'Death Valley', 'San Joaquin Valley', 'Sacramento Valley'],
          correctIndex: 0,
          explanation: 'Correct answer is Santa Clara Valley.',
        ),
        MCQuestion(
          id: 6,
          question: 'To which sector of economic activities does manufacturing finished commodities from raw natural resources belong?',
          options: ['Secondary sector', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Secondary sector.',
        ),
        MCQuestion(
          id: 7,
          question: 'In which industrial category do traditional pottery, handloom weaving, and bamboo handicraft businesses fall?',
          options: ['Cottage or household industries', 'Large-scale public sector industries', 'Joint sector ventures', 'Cooperative corporate sector'],
          correctIndex: 0,
          explanation: 'Correct answer is Cottage or household industries.',
        ),
        MCQuestion(
          id: 8,
          question: 'Name the pioneering private steel company established in 1907 at Sakchi (now Jamshedpur) by Jamsetji Tata.',
          options: ['TISCO (Tata Iron and Steel Company)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is TISCO (Tata Iron and Steel Company).',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000007-0004-0000-0000-000000000023',
      name: 'Modals & Active-Passive',
      subject: 'English',
      grade: 'Class 7',
      description: 'Can, could, must, should, passive voice transformations',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Which modal auxiliary verb is correctly used to express general physical ability in the past?',
          options: ['Could', 'Can', 'May', 'Shall'],
          correctIndex: 0,
          explanation: 'Correct answer is Could.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000007-0002-0000-0000-000000000019',
      name: 'Nutrition & Chemical Changes',
      subject: 'Science',
      grade: 'Class 7',
      description: 'Autotrophic/heterotrophic nutrition, neutralization',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Which green photosynthetic pigment present in plant chloroplasts absorbs solar energy?',
          options: ['Chlorophyll', 'Anthocyanin', 'Xanthophyll', 'Carotene'],
          correctIndex: 0,
          explanation: 'Correct answer is Chlorophyll.',
        ),
        MCQuestion(
          id: 2,
          question: 'What are the microscopic pores surrounded by guard cells on leaf surfaces called?',
          options: ['Stomata', 'Lenticels', 'Hydathodes', 'Xylem vessels'],
          correctIndex: 0,
          explanation: 'Correct answer is Stomata.',
        ),
        MCQuestion(
          id: 3,
          question: 'Which of the following plants is classified as an insectivorous plant?',
          options: ['Venus flytrap', 'Cuscuta (Amarbel)', 'Mushroom', 'Spirogyra'],
          correctIndex: 0,
          explanation: 'Correct answer is Venus flytrap.',
        ),
        MCQuestion(
          id: 4,
          question: 'Name the vital gas released by autotrophic green plants during photosynthesis.',
          options: ['Oxygen', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Oxygen.',
        ),
        MCQuestion(
          id: 5,
          question: 'Why do insectivorous plants trap and digest small insects even though they possess chlorophyll?',
          options: ['To obtain nitrogen compounds deficient in their boggy soil', 'Because they cannot synthesize carbohydrates via sunlight', 'To acquire extra water molecules during drought periods', 'To defend their floral petals against herbivorous animals'],
          correctIndex: 0,
          explanation: 'Correct answer is To obtain nitrogen compounds deficient in their boggy soil.',
        ),
        MCQuestion(
          id: 6,
          question: 'Name the common fungal organism that exhibits saprotrophic nutrition on stale moist bread.',
          options: ['Rhizopus (Bread mould)', 'Spirogyra', 'Amoeba', 'Paramecium'],
          correctIndex: 0,
          explanation: 'Correct answer is Rhizopus (Bread mould).',
        ),
        MCQuestion(
          id: 7,
          question: 'What characteristic taste is typically associated with acidic chemical substances?',
          options: ['Sour', 'Bitter', 'Sweet', 'Salty'],
          correctIndex: 0,
          explanation: 'Correct answer is Sour.',
        ),
        MCQuestion(
          id: 8,
          question: 'Which natural organic acid is found in sour milk and curd?',
          options: ['Lactic acid', 'Citric acid', 'Tartaric acid', 'Oxalic acid'],
          correctIndex: 0,
          explanation: 'Correct answer is Lactic acid.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000010-0002-0000-0000-000000000044',
      name: 'Optics & Electric Current',
      subject: 'Science',
      grade: 'Class 10',
      description: 'Snell law, lens formula, Ohm law, Joule heating, electromagnetic induction',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the focal length of a spherical mirror whose radius of curvature is 30 cm?',
          options: ['15 cm', '30 cm', '60 cm', '10 cm'],
          correctIndex: 0,
          explanation: 'Correct answer is 15 cm.',
        ),
        MCQuestion(
          id: 2,
          question: 'Where must an object be placed in front of a concave mirror to obtain an erect and enlarged virtual image?',
          options: ['Between the pole and principal focus', 'At the center of curvature', 'At the principal focus', 'Beyond the center of curvature'],
          correctIndex: 0,
          explanation: 'Correct answer is Between the pole and principal focus.',
        ),
        MCQuestion(
          id: 3,
          question: 'A convex mirror used on a bus has a radius of curvature of 3.0 m. If another vehicle is 5.0 m away, what is the image position?',
          options: ['+1.15 m behind the mirror', '-1.15 m in front of the mirror', '+2.50 m behind the mirror', '-2.50 m in front of the mirror'],
          correctIndex: 0,
          explanation: 'Correct answer is +1.15 m behind the mirror.',
        ),
        MCQuestion(
          id: 4,
          question: 'If the speed of light in water is 2.25 x 10^8 m/s and in vacuum is 3.0 x 10^8 m/s, find the refractive index of water.',
          options: ['1.33', '1.50', '1.25', '1.66'],
          correctIndex: 0,
          explanation: 'Correct answer is 1.33.',
        ),
        MCQuestion(
          id: 5,
          question: 'A convex lens forms a real image of the same size as the needle at 50 cm. Where is the needle located in front of the lens?',
          options: ['At 50 cm in front of the lens', 'At 25 cm in front of the lens', 'At 100 cm in front of the lens', 'At infinity'],
          correctIndex: 0,
          explanation: 'Correct answer is At 50 cm in front of the lens.',
        ),
        MCQuestion(
          id: 6,
          question: 'What is the focal length and optical nature of a lens having power +2.0 D?',
          options: ['+50 cm, convex lens', '-50 cm, concave lens', '+20 cm, convex lens', '-20 cm, concave lens'],
          correctIndex: 0,
          explanation: 'Correct answer is +50 cm, convex lens.',
        ),
        MCQuestion(
          id: 7,
          question: 'A ray of light traveling in water falls obliquely on a glass slab (n_water = 1.33, n_glass = 1.50). How does the ray bend?',
          options: ['It bends towards the normal', 'It bends away from the normal', 'It proceeds without deviation', 'It reflects totally back into water'],
          correctIndex: 0,
          explanation: 'Correct answer is It bends towards the normal.',
        ),
        MCQuestion(
          id: 8,
          question: 'If the linear magnification produced by a spherical mirror is negative (m < 0), what does it signify about the image?',
          options: ['The image is real and inverted', 'The image is virtual and erect', 'The image is diminished and erect', 'The image is virtual and magnified'],
          correctIndex: 0,
          explanation: 'Correct answer is The image is real and inverted.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000011-0005-0000-0000-000000000053',
      name: 'Python Algorithms & Logic',
      subject: 'Computer Science',
      grade: 'Class 11',
      description: 'Dictionary mappings, tuples, bubble sort, insertion sort',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the average time complexity of indexing (random access) an element in a Python list?',
          options: ['O(1)', 'O(n)', 'O(log n)', 'O(n^2)'],
          correctIndex: 0,
          explanation: 'Correct answer is O(1).',
        ),
        MCQuestion(
          id: 2,
          question: 'Which built-in Python sequence type is mutable and maintains insertion order?',
          options: ['list', 'tuple', 'frozenset', 'str'],
          correctIndex: 0,
          explanation: 'Correct answer is list.',
        ),
        MCQuestion(
          id: 3,
          question: 'Which Python dictionary method removes the specified key and returns its associated value?',
          options: ['pop()', 'remove()', 'discard()', 'delete()'],
          correctIndex: 0,
          explanation: 'Correct answer is pop().',
        ),
        MCQuestion(
          id: 4,
          question: 'What is the average-case time complexity of searching for a key in a Python dictionary?',
          options: ['O(1) (Constant time)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is O(1) (Constant time).',
        ),
        MCQuestion(
          id: 5,
          question: 'Which list method adds all elements of an iterable (e.g., another list) to the end of the list?',
          options: ['extend()', 'append()', 'insert()', 'update()'],
          correctIndex: 0,
          explanation: 'Correct answer is extend().',
        ),
        MCQuestion(
          id: 6,
          question: 'What will be the output of the list comprehension: [x**2 for x in range(5) if x % 2 == 0]?',
          options: ['[0, 4, 16]', '[1, 9]', '[0, 1, 4, 9, 16]', '[4, 16]'],
          correctIndex: 0,
          explanation: 'Correct answer is [0, 4, 16].',
        ),
        MCQuestion(
          id: 7,
          question: 'Which built-in sequence type in Python is enclosed in parentheses and is completely immutable?',
          options: ['tuple', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is tuple.',
        ),
        MCQuestion(
          id: 8,
          question: 'What is the worst-case time complexity of inserting an item at the beginning of a Python list of n elements?',
          options: ['O(n)', 'O(1)', 'O(log n)', 'O(n log n)'],
          correctIndex: 0,
          explanation: 'Correct answer is O(n).',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000006-0004-0000-0000-000000000015',
      name: 'Sentence Structure & Conjunctions',
      subject: 'English',
      grade: 'Class 6',
      description: 'Coordinating conjunctions, subordinate clauses, and idioms',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Which of the following sentences correctly links two independent clauses with a comma and coordinating conjunction?',
          options: ['The school bell rang, and the students hurried out to the field.', 'Because the school bell rang the students hurried out.', 'The school bell rang although the students hurried out.', 'The school bell rang when the students hurried out.'],
          correctIndex: 0,
          explanation: 'Correct answer is The school bell rang, and the students hurried out to the field..',
        ),
        MCQuestion(
          id: 2,
          question: 'What mnemonic acronym represents the seven coordinating conjunctions: For, And, Nor, But, Or, Yet, So?',
          options: ['FANBOYS', 'PEMDAS', 'HOMES', 'VIBGYOR'],
          correctIndex: 0,
          explanation: 'Correct answer is FANBOYS.',
        ),
        MCQuestion(
          id: 3,
          question: 'Which of the following sentences represents a complex sentence containing an independent clause and a dependent clause?',
          options: ['When the train pulled into the station, the passengers stood up.', 'The train arrived and the passengers quickly boarded it.', 'The train blew its loud horn at the junction.', 'The train was late, but the passengers waited patiently.'],
          correctIndex: 0,
          explanation: 'Correct answer is When the train pulled into the station, the passengers stood up..',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0004-0000-0000-000000000031',
      name: 'Subject-Verb Concord & Clauses',
      subject: 'English',
      grade: 'Class 8',
      description: 'Compound subjects, either/neither rules, noun clauses',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'Select the grammatically accurate sentence showing proper subject-verb agreement:',
          options: ['The quality of these organic Kashmiri apples was exceptional.', 'The quality of these organic Kashmiri apples were exceptional.', 'The qualities of this organic Kashmiri apple was poor.', 'The quality of these organic Kashmiri apples are having praise.'],
          correctIndex: 0,
          explanation: 'Correct answer is The quality of these organic Kashmiri apples was exceptional..',
        ),
        MCQuestion(
          id: 2,
          question: 'Identify the sentence that contains a noun clause functioning as the object of a preposition:',
          options: ['Pay close attention to what your mentor advises.', 'The ancient manuscript which is in the glass display is fragile.', 'Because he was ill, he missed the chemistry practical exam.', 'I reached the airport after the flight had departed.'],
          correctIndex: 0,
          explanation: 'Correct answer is Pay close attention to what your mentor advises..',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000010-0001-0000-0000-000000000042',
      name: 'Trigonometry & Arithmetic Progression',
      subject: 'Mathematics',
      grade: 'Class 10',
      description: 'Trigonometric ratios, identities, nth term and sum of AP',
      questions: const [
        MCQuestion(
          id: 1,
          question: 'In the Arithmetic Progression: 2, 7, 12, ..., what is the common difference d?',
          options: ['5', '2', '7', '-5'],
          correctIndex: 0,
          explanation: 'Correct answer is 5.',
        ),
        MCQuestion(
          id: 2,
          question: 'What is the 10th term of the Arithmetic Progression: 5, 8, 11, 14, ...?',
          options: ['32', '35', '29', '30'],
          correctIndex: 0,
          explanation: 'Correct answer is 32.',
        ),
        MCQuestion(
          id: 3,
          question: 'Which term of the AP: 21, 18, 15, ... is -81?',
          options: ['35th term', '34th term', '36th term', '32nd term'],
          correctIndex: 0,
          explanation: 'Correct answer is 35th term.',
        ),
        MCQuestion(
          id: 4,
          question: 'If the 3rd and 9th terms of an AP are 4 and -8 respectively, which term of this AP is 0?',
          options: ['5th term', '4th term', '6th term', '7th term'],
          correctIndex: 0,
          explanation: 'Correct answer is 5th term.',
        ),
        MCQuestion(
          id: 5,
          question: 'The sum of the first n terms of an AP is given by S_n = 3n^2 + 5n. Find its 15th term.',
          options: ['92', '88', '90', '96'],
          correctIndex: 0,
          explanation: 'Correct answer is 92.',
        ),
        MCQuestion(
          id: 6,
          question: 'Find the sum of the first 24 terms of the AP: 5, 2, -1, -4, ...',
          options: ['-708', '-696', '-720', '708'],
          correctIndex: 0,
          explanation: 'Correct answer is -708.',
        ),
        MCQuestion(
          id: 7,
          question: 'How many terms of the AP: 24, 21, 18, ... must be taken so that their sum is 78?',
          options: ['4 or 13', '4 only', '13 only', '5 or 12'],
          correctIndex: 0,
          explanation: 'Correct answer is 4 or 13.',
        ),
        MCQuestion(
          id: 8,
          question: 'What is the sum of the first 100 positive integers?',
          options: ['5050', '5000', '5100', '10100'],
          correctIndex: 0,
          explanation: 'Correct answer is 5050.',
        ),
      ],
    ),
  ];

  /// Filter classes by educational board (CBSE, ICSE, BSEB, WBBSE, DBSE)
  static List<SeedClass> getClassesByBoard(String? board) {
    if (board == null || board.trim().isEmpty) return classes;
    final b = board.trim().toUpperCase();
    return classes.where((c) => c.board.toUpperCase() == b).toList();
  }

  /// Resolve topics matching subject and grade
  static List<SeedTopic> getTopicsFor({required String subject, String? grade}) {
    final cleanSubj = subject.trim().toLowerCase();
    final cleanGrade = grade?.trim().toLowerCase();

    return topics.where((t) {
      final tSubj = t.subject.toLowerCase();
      bool matchSubj = tSubj.contains(cleanSubj) || cleanSubj.contains(tSubj);
      if (cleanSubj.contains('math') && tSubj.contains('math')) matchSubj = true;
      if (cleanSubj.contains('phys') && (tSubj.contains('phys') || tSubj.contains('science'))) matchSubj = true;
      if (cleanSubj.contains('chem') && (tSubj.contains('chem') || tSubj.contains('science'))) matchSubj = true;
      if (cleanSubj.contains('bio') && (tSubj.contains('bio') || tSubj.contains('science'))) matchSubj = true;
      if (cleanSubj.contains('code') || cleanSubj.contains('prog') || cleanSubj.contains('comp')) {
        if (tSubj.contains('comp') || tSubj.contains('code')) matchSubj = true;
      }
      if (cleanSubj.contains('hist') || cleanSubj.contains('social')) {
        if (tSubj.contains('social') || tSubj.contains('hist')) matchSubj = true;
      }
      if (!matchSubj) return false;

      if (cleanGrade != null && cleanGrade.isNotEmpty) {
        return t.grade.toLowerCase().contains(cleanGrade) || cleanGrade.contains(t.grade.toLowerCase());
      }
      return true;
    }).toList();
  }

  /// Get fallback learning content response from seed dataset
  static LearningContentResponse getLearningContentFor(LearningRequest req) {
    final matchingTopics = getTopicsFor(subject: req.subject, grade: req.grade);
    SeedTopic? selected;
    if (req.topic != null && req.topic!.isNotEmpty) {
      final tName = req.topic!.toLowerCase();
      selected = matchingTopics.firstWhere(
        (t) => t.name.toLowerCase().contains(tName) || tName.contains(t.name.toLowerCase()),
        orElse: () => matchingTopics.isNotEmpty ? matchingTopics.first : topics.first,
      );
    } else {
      selected = matchingTopics.isNotEmpty ? matchingTopics.first : topics.first;
    }

    return LearningContentResponse(
      buildingId: req.buildingId,
      buildingName: req.buildingName,
      subject: req.subject,
      topic: selected.name,
      explanation: selected.description.isNotEmpty
          ? selected.description
          : 'Master fundamental principles of ${selected.name} calibrated for ${req.grade ?? "Class 10"}.',
      questions: selected.questions.isNotEmpty ? selected.questions : const [
        MCQuestion(
          id: 1,
          question: 'What is the primary governing principle of this lesson?',
          options: ['Conservation of systemic balance', 'Random divergence of constants', 'Unconstrained scalar decay', 'Arbitrary index mapping'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation and balance across dimensional systems.',
        ),
      ],
      audioAvailable: false,
      source: 'curriculum-seed-dataset',
      cacheKey: 'seed_${req.subject}_${req.buildingId}_${req.studentLevel}',
    );
  }

  /// Resolves the deterministic Class UUID for a given grade and curriculum board.
  static String findClassId({required String grade, required String board}) {
    final g = grade.trim().toLowerCase();
    final b = board.trim().toUpperCase();
    for (final c in classes) {
      if (c.name.toLowerCase() == g && c.board.toUpperCase() == b) {
        return c.id;
      }
    }
    for (final c in classes) {
      if (c.name.toLowerCase() == g) {
        return c.id;
      }
    }
    return '00000010-0001-0000-0000-000000000000';
  }
}

