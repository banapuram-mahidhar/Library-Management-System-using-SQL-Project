-- LIBRARAY MANAGEMENT SYSTEM PROJECT --
create database library_project;

create table branch(
branch_id varchar(10) primary key,
manager_id	varchar(10),
branch_address	varchar(50),
contact_no varchar(10)
);
alter table branch
modify contact_no varchar(20);

create table employees(
emp_id varchar(10) primary key,
emp_name varchar(25),
position varchar(25),
salary int,
branch_id varchar (25)
);

create table books(
isbn varchar(25) primary key,	
book_title varchar(75),	
category varchar(25),	
rental_price float,
status	varchar(15),
author	varchar(35),
publisher varchar(55)
);

create table members(
member_id varchar(10) primary key,	
member_name	varchar(20),
member_address	varchar(20),
reg_date date
);

create table issued_status(
issued_id varchar(10) primary key,
issued_member_id varchar(10),	
issued_book_name varchar(65),	
issued_date	date,
issued_book_isbn varchar (20),	
issued_emp_id varchar (10)
);


create table return_status(
return_id varchar(10) primary key,
issued_id	 varchar(10),
return_book_name varchar(75),
return_date	date,
return_book_isbn varchar(20)
);

-- FOREIGN KEY --
alter table issued_status
add constraint fk_members
foreign key (issued_member_id)
references members(member_id);

alter table issued_status
add constraint fk_books
foreign key (issued_book_isbn)
references books(isbn);

alter table issued_status
add constraint fk_emp_id
foreign key (issued_emp_id)
references employees(emp_id);

alter table employees
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id);

alter table return_status
add constraint fk_issued_status
foreign key (issued_id)
references issued_status(issued_id);

select * from books ;
select * from branch ;
select * from employees;
select * from members;
select * from return_status;
select * from issued_status;

-- projec task

-- CURD OPERATIONS 
-- 1. Create a New Book Record -- ("978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books 
(isbn , book_title ,	category , rental_price ,	status ,	author ,	publisher )
value
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books ;

-- 2. Update an Existing Member's Address SET member_address = '125 Oak St' WHERE member_id = 'C103'
update members
set member_address = '125 Oak St'
where member_id = 'C103';
select * from members;

-- 3.  Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status
where issued_id = 'IS121';
select * from issued_status;

-- 4.  Retrieve All Books Issued by a Specific Employee -- Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status
where issued_emp_id = 'E101';

-- 5. List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_emp_id, count(*) from issued_status
group by issued_emp_id
having count(*)>1;

-- CTAS (Create Table As Select)
 -- 1. Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

create table book_count
as
select b.isbn, b.book_title,count(ist.issued_id) as no_issued
from  books as b
join issued_status as ist
on ist.issued_book_isbn = b.isbn
group by b.isbn, b.book_title;

select * from book_count;

-- Data Analysis & Findings

-- 1. Retrieve All Books in a Specific Category:
select * from books
where category = 'Classic';

-- 2.  Find Total Rental Income by Category:
select b.category,sum(b.rental_price),count(*)
from issued_status as ist
join books as b 
on ist .issued_book_isbn = b.isbn
group by
b.category;

-- 3. List Members Who Registered in the Last 180 Days:

insert into members (member_id, member_name, member_address, reg_date)
values
('C111','mahi','180 hyd main','2025-11-14'),
('C115','hari','182 hiv main','2025-10-14'),
('C161','rana','183 lan main','2025-09-14'),
('C141','pooja','140 delhi main','2025-11-11');
select * from members;
select * from members
where reg_date >= curdate()-interval 180 day;

-- 4. List Employees with Their Branch Manager's Name and their branch details:
select 
 e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
from branch as b
join employees as e1
on b.branch_id = e1.branch_id
join employees as e2
on b.manager_id = e2.emp_id;

-- 5. Create a Table of Books with Rental Price Above a Certain Threshold:
create table expensive_book AS
select * FROM books
where rental_price >= 7.00;
select * from expensive_book;

-- 6. Retrieve the List of Books Not Yet Returned
select 
isu.issued_id,
isu.issued_book_name,
isu.issued_date
from issued_status as isu
left join return_status as rs
on isu.issued_id = rs.issued_id
where rs.return_id is null;

-- ADVANCE SQL OPERATIONS
 -- 1. For performing Advance SQL Operations We are making some changes in the project
 
 INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', curdate() - INTERVAL 24 day,  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', curdate()- INTERVAL 13 day,  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', curdate() - INTERVAL 7 day,  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', curdate() - INTERVAL 32 day,  '978-0-375-50167-0', 'E101');

select * from issued_status;

 -- addind new column in return_status
alter table return_status
add column book_quality varchar(15) default('Good');

update return_status
set book_quality = 'Damaged'
where issued_id 
in ('IS112','IS117','IS118');

select * from return_status;

/* 2. Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period).
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
   -- issued_status == member == books == return_status
   -- filter books which is return
   -- overdue >30 days
select * from books;
select * from members;
select * from return_status;
select * from issued_status;

select 
isu.issued_member_id,
mem.member_name,
b.book_title,
isu.issued_date,
curdate()-isu.issued_date as over_due_days
from issued_status as isu
join members as mem
on isu.issued_member_id = mem.member_id
join books as b
on b.book_title = isu.issued_book_name
left join return_status as re
on isu.issued_id = re.issued_id
where (curdate()-isu.issued_date)>30
and re.return_date is null;

/* 3.  Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned 
(based on entries in the return_status table). */

DELIMITER $$

CREATE PROCEDURE add_return_records (
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Step 1: Insert return details into return_status table
    INSERT INTO return_status (
        return_id,
        issued_id,
        return_date,
        book_quality
    )
    VALUES (
        p_return_id,
        p_issued_id,
        CURDATE(),
        p_book_quality
    );

    -- Step 2: Retrieve ISBN and book name from issued_status table
    SELECT
        issued_book_isbn,
        issued_book_name
    INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Step 3: Update book status to 'Yes' (Available)
    UPDATE books
    SET status = 'Yes'
    WHERE isbn = v_isbn;

    -- Step 4: Display confirmation message
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;

END $$

DELIMITER ;

-- TESTING FUNCTION --
select * from issued_status;

select * from books;

select * from return_status;

CALL add_return_records('RS121', 'IS135', 'Good');

/* 4. Branch Performance Report
Create a query that generates a performance report for each branch,
showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals. */


create table branch_report
as
select 
b.branch_id,
b.manager_id,
count(isu.issued_id) as number_of_book_issued,
count(rs.return_id) as number_of_book_return,
sum(bk.rental_price) as total_revenu
from issued_status as isu
join employees as emp
on isu.issued_emp_id = emp.emp_id
join branch as b
on emp.branch_id = b.branch_id
left join return_status as rs
on rs.issued_id = isu.issued_id
join books as bk
on bk.isbn = isu.issued_book_isbn
group by b.branch_id,
b.manager_id;

select * from branch_report;

/* 5. CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing
 members who have issued at least one book in the last 6 months.
*/
create table active_members
as
select *
from issued_status as isu
join members as mem 
on isu.issued_member_id = mem.member_id
where issued_date >= date_sub(curdate(),interval 6 month);

select * from active_members;

/*
6. Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

select 
emp.emp_name,
br.*,
count(isu.issued_id) as no_of_books_issued
from issued_status as isu
join employees as emp
on isu.issued_emp_id = emp.emp_id
join branch as br
on br.branch_id = emp.branch_id
group by emp.emp_name,br.branch_id,br.branch_address;

/* 7.  CREATE A STORED PROCEDURE
Issue a book only if it is available (status = 'yes').
If issued, update the book status to no (not available).
If not available, return an error message.
*/

delimiter $$
drop procedure if exists issue_book $$
create procedure issue_book (
	in p_issued_id varchar(10),
    in p_issued_member_id varchar(10),
    in p_issued_book_isbn varchar(20),
    in p_issued_emp_id varchar(10)
)
begin
	declare v_status varchar (10);
    -- step:1 check book avabilility --
    select status
    into v_status
    from books
    where isbn = p_issued_book_isbn ;
    -- step :2 if book is available , issue it --
    if v_status = 'yes' then
    insert into issued_status (issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
    values (p_issued_id,p_issued_member_id,curdate(),p_issued_book_isbn,p_issued_emp_id);
	
    update books
    set status = 'no'
	where isbn = p_issued_book_isbn;
    
    select concat('Book issued successfully . book ISBN : ', p_issued_book_isbn) as message;
    
    else
		select concat('sorry the requested book is currently unavailable book ISBN : ',p_issued_book_isbn) AS error_message;
	
	end if;
end $$
delimiter ;

-- testing --

select * from issued_status;
-- 978-0-06-112008-4 yes --
-- 978-0-375-41398-8 no --
call issue_book ('IS155','C108','978-0-06-112008-4','E104');
call issue_book ('IS155','C108','978-0-375-41398-8 ','E104');

/* 8. Create Table As Select (CTAS) Objective:
Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
 Description: Write a CTAS query to create a new table that lists each member and
 the books they have issued but not returned within 30 days. 
 The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
 The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines */
 select * from issued_status;
 select  * from return_status;
 select 
 isu.issued_member_id	as member_id,
 count(isu.issued_id) as no_of_overduebooks,
 sum(
	greatest( 
		datediff( curdate() , issued_date )-30 ,0
		) * 0.50
  ) as total_fine
  
 From issued_status as isu
 left join return_status as rs 
 on isu.issued_id = rs.issued_id
 
 where rs.return_date is null
 and datediff( curdate() , issued_date ) > 30
 group by isu.issued_member_id;
 
-- PROJECT COMPLETED --