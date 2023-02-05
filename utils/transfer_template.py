# 转换verilog代码段用于生成vscode可用的代码段模板
import os

def transfer(file_name, indent_num = 4):
    """
        接收代码段生成vscode可用的模板
        Args:
            file_name: str, 代码段文件路径
    """
    template_name = "".join(file_name.split(".")) + "_tmpl.txt"
    f_template = open(template_name, "w")
    with open(file_name, "r") as f:
        code_lines = f.readlines()
        line_num = len(code_lines) 
        for i in range(line_num):
            line = code_lines[i]
            line = line.rstrip()
            
            # replace tab and blank at first
            line.replace("\t", "\\t")
            blank_first = 0
            while True:
                if blank_first >= len(line) - 1 or line[blank_first] != " ":
                    break
                if line[blank_first] == " ":
                    blank_first += 1
            line = "\\t"*(blank_first//indent_num) + line.lstrip()

            end_character = ",\n" if i < line_num - 1 else ""
            f_template.write("\""+ line + "\"" + end_character)
    f_template.close()

if __name__ == "__main__":
    file_name = input("Input the code snippet file path:")
    transfer(file_name)