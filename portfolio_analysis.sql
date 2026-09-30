-- Medical Claims SQL Portfolio
-- Uses the original repository sample records. Run once in an empty practice database.

CREATE TABLE Patients (
  PatientID INT PRIMARY KEY NOT NULL UNIQUE,
  FirstName VARCHAR(50) NOT NULL,
  LastName VARCHAR(50) NOT NULL,
  DOB DATE NOT NULL,
  Address VARCHAR(100) NOT NULL,
  PhoneNumber VARCHAR(15) NOT NULL
);


CREATE TABLE Providers (
  ProviderID INT PRIMARY KEY NOT NULL UNIQUE,
  ProviderName VARCHAR(100) NOT NULL,
  Address VARCHAR(100) NOT NULL,
  PhoneNumber VARCHAR(15) NOT NULL,
  Specialty VARCHAR(50) NOT NULL
);


CREATE TABLE Claims (
  ClaimID INT PRIMARY KEY NOT NULL UNIQUE,
  PatientID INT NOT NULL,
  ProviderID INT NOT NULL,
  ServiceDate DATE NOT NULL,
  ServiceType VARCHAR(50) NOT NULL,
  Amount DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
  FOREIGN KEY (ProviderID) REFERENCES Providers(ProviderID)
);



INSERT INTO Patients (PatientID, FirstName, LastName, DOB, Address, PhoneNumber)
VALUES
  (1, 'John', 'Doe', '1990-01-01', '123 Main St, Some State USA', '555-1234'),
  (2, 'Jane', 'Smith', '1985-03-15', '456 Oak Ave, Some State USA', '555-5678'),
  (3, 'Bob', 'Johnson', '1975-12-25', '789 Elm St, Some State USA', '555-9101'),
  (4, 'Alice', 'Brown', '2000-05-07', '321 Maple Rd, Some State USA', '555-1212'),
  (5, 'Sam', 'Lee', '1995-09-10', '654 Pine Ln, Some State State USA', '555-1313');


INSERT INTO Providers (ProviderID, ProviderName, Address, PhoneNumber, Specialty)
VALUES
  (1, 'Blah Blah Medical Center', '10 Hospital Dr, Some State USA', '555-2468', 'General Practice'),
  (2, 'Blah Blah Mental Health', '20 Dentist St, Some State USA', '555-3690', 'Mental Health'),
  (3, 'Blah Blah Chiropractic', '30 Spine Rd, Some State USA', '555-4822', 'Chiropractic'),
  (4, 'Blah Blah Vision Center', '40 Eye Ave, Some State USA', '555-5955', 'Optometry'),
  (5, 'Blah Blah Physical Therapy', '50 Mobility Blvd, State USA', '555-7171', 'Physical Therapy');


INSERT INTO Claims (ClaimID, PatientID, ProviderID, ServiceDate, ServiceType, Amount)
VALUES
  (1, 1, 1, '2022-01-01', 'Office Visit', 100.00),
  (2, 2, 2, '2022-01-15', 'Teeth Cleaning', 80.00),
  (3, 3, 3, '2022-02-01', 'Spinal Adjustment', 75.00),
  (4, 4, 4, '2022-02-15', 'Eye Exam', 50.00),
  (5, 5, 5, '2022-03-01', 'Physical Therapy', 200.00),
  (6, 1, 2, '2022-03-15', 'Fillings', 150.00),
  (7, 2, 3, '2022-04-01', 'Massage Therapy', 90.00),
  (8, 3, 4, '2022-04-15', 'Contact Lenses', 100.00),
  (9, 4, 5, '2022-05-01', 'Occupational Therapy', 175.00),
  (10, 5, 1, '2022-05-15', 'Lab Work', 75.00);

-- Portfolio summary: claim counts and submitted amounts, not paid reimbursements.
SELECT COUNT(*) AS ClaimCount, SUM(Amount) AS TotalClaimAmount,
       ROUND(AVG(Amount), 2) AS AverageClaimAmount
FROM Claims;

-- Provider activity, including providers with no claims.
SELECT p.ProviderID, p.ProviderName, COUNT(c.ClaimID) AS ClaimCount,
       COALESCE(SUM(c.Amount), 0) AS TotalClaimAmount
FROM Providers p LEFT JOIN Claims c ON p.ProviderID = c.ProviderID
GROUP BY p.ProviderID, p.ProviderName
ORDER BY TotalClaimAmount DESC, p.ProviderID;

-- Monthly claim volume and amount (portable date-range grouping).
SELECT SUBSTR(CAST(ServiceDate AS CHAR(10)), 1, 7) AS ServiceMonth,
       COUNT(*) AS ClaimCount, SUM(Amount) AS TotalClaimAmount
FROM Claims
GROUP BY SUBSTR(CAST(ServiceDate AS CHAR(10)), 1, 7)
ORDER BY ServiceMonth;

-- Members whose total claim amount exceeds 200.
SELECT p.PatientID, COUNT(c.ClaimID) AS ClaimCount, SUM(c.Amount) AS TotalClaimAmount
FROM Patients p JOIN Claims c ON p.PatientID = c.PatientID
GROUP BY p.PatientID
HAVING SUM(c.Amount) > 200
ORDER BY TotalClaimAmount DESC, p.PatientID;

-- Missing relationships or invalid amounts: expected 0 for this sample.
SELECT COUNT(*) AS InvalidClaims
FROM Claims c
LEFT JOIN Patients p ON c.PatientID = p.PatientID
LEFT JOIN Providers pr ON c.ProviderID = pr.ProviderID
WHERE p.PatientID IS NULL OR pr.ProviderID IS NULL OR c.Amount <= 0;